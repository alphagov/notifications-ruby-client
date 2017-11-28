require 'time'

module Notifications
  class Client
    class ReceivedText
      FIELDS = %i(
        id
        created_at
        content
        notify_number
        service_id
        user_number
      ).freeze

      attr_reader(*FIELDS)

      def initialize(received_text)
        FIELDS.each do |field|
          instance_variable_set(:"@#{field}", received_text.fetch(field.to_s, nil))
        end
      end

      def created_at
        value = instance_variable_get(:@created_at)
        Time.parse(value)
      rescue StandardError
        value
      end
    end
  end
end
