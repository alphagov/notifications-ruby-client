module Notifications
  class Client
    class ResponseNotification
      FIELDS = %i(
      id
      reference
      content
      template
      uri
    ).freeze

      attr_reader(*FIELDS)

      def initialize(notification)
        FIELDS.each do |field|
          instance_variable_set(:"@#{field}", notification.fetch(field.to_s, nil))
        end
      end
    end
  end
end
