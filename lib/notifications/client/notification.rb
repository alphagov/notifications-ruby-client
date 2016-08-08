module Notifications
  class Client
    class Notification
      FIELDS = [
        :id,
        :api_key,
        :billable_units,
        :to,
        :subject,
        :body,
        :job,
        :notification_type,
        :status,
        :service,
        :sent_at,
        :sent_by,
        :template,
        :template_version,
        :reference,
        :created_at,
        :updated_at
      ].freeze

      attr_reader(*FIELDS)

      def initialize(notification)
        FIELDS.each do |field|
          instance_variable_set(
            :"@#{field}",
            notification.fetch(field.to_s)
          )
        end
      end

      [
        :sent_at,
        :created_at,
        :updated_at
      ].each do |field|
        define_method field do
          begin
            value = instance_variable_get(:"@#{field}")
            Time.parse value
          rescue
            value
          end
        end
      end
    end
  end
end
