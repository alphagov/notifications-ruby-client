require "base64"
require "net/https"
require "uri"
require "jwt"
require_relative "request_error"

module Notifications
  class Client
    class Speaker
      include ErrorHandling

      attr_reader :base_url
      attr_reader :service_id
      attr_reader :secret_token

      BASE_PATH = "/v2/notifications".freeze
      USER_AGENT = "NOTIFY-API-RUBY-CLIENT/#{Notifications::Client::VERSION}".freeze

      ##
      # @param secret [String] your service API secret
      # @param base_url [String] host URL. This is the address to perform the requests.
      #                          If left nil the production url is used.
      def initialize(secret_token = nil, base_url = nil)
        @service_id = secret_token[secret_token.length - 73..secret_token.length - 38]
        @secret_token = secret_token[secret_token.length - 36..secret_token.length]
        @base_url = base_url || PRODUCTION_BASE_URL

        validate_uuids!
      end

      ##
      # @param kind [String] 'email', 'sms' or 'letter'
      # @param form_data [Hash]
      # @option form_data [String] :phone_number
      #   phone number of the sms recipient
      # @option form_data [String] :email_address
      #   email address of the email recipent
      # @option form_data [String] :template
      #   template to render in notification
      # @option form_data [Hash] :personalisation
      #   fields to use in the template
      # @option form_data [String] :reference
      #   A reference specified by the service for the notification. Get all notifications can be filtered by this reference.
      #   This reference can be unique or used used to refer to a batch of notifications.
      #   Can be an empty string or nil, when you do not require a reference for the notifications.
      # @option form_data [String] :email_reply_to_id
      #   id of the email address that replies to email notifications will be sent to
      # @option form_data [String] :sms_sender_id
      #   id of the sender to be used for an sms notification
      # @see #perform_request!
      def post(kind, form_data)
        request = Net::HTTP::Post.new(
          "#{BASE_PATH}/#{kind}",
          headers
        )
        request.body = form_data.is_a?(Hash) ? form_data.to_json : form_data
        perform_request!(request)
      end

      ##
      # @param id [String]
      # @param options [Hash] query
      # @see #perform_request!
      def get(id = nil, options = {})
        path = BASE_PATH.dup
        path << "/" << id if id
        path << "?" << URI.encode_www_form(options) if options.any?
        request = Net::HTTP::Get.new(path, headers)
        perform_request!(request)
      end

      ##
      # @param url path of endpoint
      # @param id [String]
      # @param options [Hash] query
      # @see #perform_request!
      def get_with_url(url, options = {})
        path = url
        path << "?" << URI.encode_www_form(options) if options.any?
        request = Net::HTTP::Get.new(path, headers)
        perform_request!(request)
      end

      ##
      # @param url [String] path of the endpoint
      # @param form_data [Hash]
      # @option form_data [String] :template_id
      #   id of the template to render
      # @option form_data [Hash] :personalisation
      #   fields to use in the template
      # @see #perform_request!
      def post_with_url(url, form_data)
        request = Net::HTTP::Post.new(
          url,
          headers
        )
        request.body = form_data.is_a?(Hash) ? form_data.to_json : form_data
        perform_request!(request)
      end

      ##
      # @param reference [String] reference of the notification
      # @param pdf_file [File] PDF file opened for reading
      # @see #perform_request!
      def post_precompiled_letter(reference, pdf_file, postage = nil)
        content = Base64.strict_encode64(pdf_file.read)
        form_data = { reference: reference, content: content }

        if postage != nil
          form_data[:postage] = postage
        end

        request = Net::HTTP::Post.new(
          "#{BASE_PATH}/letter",
          headers
        )
        request.body = form_data.to_json
        perform_request!(request)
      end

      def get_pdf_for_letter(id)
        path = "/v2/notifications/" << id << "/pdf"
        request = Net::HTTP::Get.new(path, headers)

        # can't use `perform_request!` because we're just returning raw binary data
        response = open(request)
        if response.is_a?(Net::HTTPClientError) || response.is_a?(Net::HTTPServerError)
          raise build_error(response)
        else
          response.body
        end
      end

    private

      ##
      # @return [Hash] JSON parsed response
      # @raise [RequestError] if request is
      #   not successful
      def perform_request!(request)
        response = open(request)
        if response.is_a?(Net::HTTPClientError) || response.is_a?(Net::HTTPServerError)
          raise build_error(response)
        else
          JSON.parse(response.body)
        end
      end

      def open(request)
        uri = URI.parse(@base_url)
        Net::HTTP.start(uri.host, uri.port, :ENV, use_ssl: uri.scheme == 'https') do |http|
          http.request(request)
        end
      end

      def headers
        {
          "User-agent" => USER_AGENT,
          "Content-Type" => "application/json",
          "Authorization" => "Bearer " + jwt_token
        }
      end

      def jwt_token
        payload = {
          iss: @service_id,
          iat: Time.now.to_i
        }
        JWT.encode payload, @secret_token, "HS256"
      end

      def validate_uuids!
        contextual_message = [
          "This error is probably caused by initializing the Notifications client with an invalid API key.",
          "You can generate a new API key by logging into Notify and visiting the 'API integration' page:",
          "https://www.notifications.service.gov.uk",
        ].join("\n")

        UuidValidator.validate!(@service_id, contextual_message)
        UuidValidator.validate!(@secret_token, contextual_message)
      end
    end
  end
end
