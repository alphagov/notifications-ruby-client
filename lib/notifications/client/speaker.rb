require "net/https"
require "uri"
require "jwt"

module Notifications
  class Client
    class Speaker
      USER_AGENT = "NOTIFY-API-RUBY-CLIENT"
      ##
      # @param base_url [String] host URL. This is
      #   the address to which we perform the POST
      # @param service_id [String] your service
      #   API identifier
      # @param secret [String] your service API
      #   secret
      def initialize(base_url, service_id, secret)
        @secret = secret
        @base_url = base_url
        @service_id = service_id
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
      def post(kind, form_data)
        request = Net::HTTP::Post.new(
          "/notifications/#{kind}",
          headers
        )
        request.body = form_data
        response = http.request(request)
        JSON.parse(response.body)["data"]
      end

      private

      def http
        Net::HTTP.new(uri.host, uri.port)
      end

      def uri
        @uri ||= URI.parse(@base_url)
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
        JWT.encode payload, @secret, "HS256"
      end
    end
  end
end
