module Notifications
  class Client
    class RequestError < StandardError
      attr_reader :code, :message

      def initialize(response)
        @code = response.code
        @message = message_from(response.body)
      end

      def to_s
        "#{code} #{message}"
      end

      def message_from(body)
        JSON.parse(body).fetch("message")
      rescue JSON::ParserError
        body
      end
    end
  end
end
