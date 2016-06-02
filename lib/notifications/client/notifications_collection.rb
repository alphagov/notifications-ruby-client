module Notifications
  class Client
    class NotificationsCollection
      attr_reader :links,
                  :total,
                  :page_size,
                  :collection

      def initialize(response)
        @links = response["links"]
        @total = response["total"]
        @page_size = response["page_size"]
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
