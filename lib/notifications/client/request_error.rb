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
        JSON.parse(body).fetch('errors')
      rescue JSON::ParserError
        body
      end
    end

    class ClientError < RequestError; end
    class BadRequestError < ClientError; end
    class AuthError < ClientError; end
    class NotFoundError < ClientError; end
    class RateLimitError < ClientError; end

    class ServerError < RequestError; end

    module ErrorHandling
      def build_error(response)
        error_class_for_code(response.code.to_i).new(response)
      end

      def error_class_for_code(code)
        case code
        when 400
          BadRequestError
        when 403
          AuthError
        when 404
          NotFoundError
        when 429
          RateLimitError
        when (400..499)
          ClientError
        when (500..599)
          ServerError
        else
          RequestError
        end
      end
    end
  end
end
