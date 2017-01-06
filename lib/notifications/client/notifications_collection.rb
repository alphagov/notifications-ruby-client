module Notifications
  class Client
    class NotificationsCollection
      attr_reader :links,
                  :collection

      def initialize(response)
        @links = response["links"]
        @collection = collection_from(response["notifications"])
      end

      def collection_from(notifications)
        notifications.map do |notification|
          Notification.new(notification)
        end
      end
    end
  end
end
