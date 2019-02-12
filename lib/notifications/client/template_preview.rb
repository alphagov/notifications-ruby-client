module Notifications
  class Client
    class TemplatePreview
      FIELDS = %i(
        id
        version
        body
        subject
        type
        html
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
