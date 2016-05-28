module Notifications
  class Client
    class ResponseNotification
      attr_reader :id

      def initialize(response)
        @id = response["data"]["notification"]["id"]
      end
    end
  end
end
