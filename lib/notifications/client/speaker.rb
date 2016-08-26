require "net/https"
require "uri"
require "jwt"
require "notifications/client/request_error"

module Notifications
  class Client
    class Speaker
      attr_reader :base_url

      BASE_PATH = "/notifications".freeze
      USER_AGENT = "NOTIFY-API-RUBY-CLIENT/#{Notifications::Client::VERSION}".freeze

      ##
      # @param service_id [String] your service
      #   API identifier
      # @param secret [String] your service API
      #   secret
      # @param base_url [String] host URL. This is
      #   the address to perform the requests
      def initialize(service_id, secret_token, base_url = nil)
        @service_id = service_id
        @secret_token = secret_token
        @base_url = base_url || PRODUCTION_BASE_URL
      end

      ##
      # @param kind [String] 'email' or 'sms'
      # @param form_data [Hash]
      # @option form_data [String] :to recipient
      #   to notify (sms or email)
      # @option form_data [String] :template
      #   template to render in notification
      # @option form_data [Hash] :personalisation
      #   fields to use in the template
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
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
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
