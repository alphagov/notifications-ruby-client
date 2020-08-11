require 'time'

module Notifications
  class Client
    class Template
      FIELDS = %i(
        id
        type
        name
        created_at
        updated_at
        created_by
        version
        body
        subject
        letter_contact_block
      ).freeze

      attr_reader(*FIELDS)

      def initialize(notification)
        FIELDS.each do |field|
          instance_variable_set(:"@#{field}", notification.fetch(field.to_s, nil))
        end
      end

      %i(
        created_at
        updated_at
      ).each do |field|
        define_method field do
          begin
            value = instance_variable_get(:"@#{field}")
            Time.parse value
          rescue StandardError
            value
          end
        end
      end
    end
  end
end
