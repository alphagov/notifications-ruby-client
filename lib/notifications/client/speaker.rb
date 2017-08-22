require "net/https"
require "uri"
require "jwt"
require "notifications/client/request_error"

module Notifications
  class Client
    class Speaker
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

    private

      ##
      # @return [Hash] JSON parsed response
      # @raise [RequestError] if request is
      #   not successful
      def perform_request!(request)
        response = open(request)
        if response.is_a?(Net::HTTPClientError)
          raise RequestError.new(response)
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
    end
  end
end
