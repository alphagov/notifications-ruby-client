require "notifications/client/version"
require "jwt"

module Notifications
  class Client
    def initialize(base_url, service_id, secret)
      @secret = secret
      @base_url = base_url
      @service_id = service_id
    end

    private

    def jwt_token
      payload = {
        iss: @service_id,
        iat: Time.now.to_i
      }
      JWT.encode payload, @secret, "HS256"
    end
  end
end
