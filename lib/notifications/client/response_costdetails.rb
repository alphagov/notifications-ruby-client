require 'time'

module Notifications
  class Client
    class CostDetails
      FIELDS = %i(
        billable_sms_fragments
        international_rate_multiplier
        sms_rate
        billable_sheets_of_paper
        postage
      ).freeze

      attr_reader(*FIELDS)

      def initialize(cost_details)
        FIELDS.each do |field|
          instance_variable_set(:"@#{field}", cost_details.fetch(field.to_s, nil))
        end
      end

      %i(
        billable_sms_fragments
        international_rate_multiplier
        sms_rate
        billable_sheets_of_paper
        postage
      ).each do |field|
        define_method field do
          instance_variable_get(:"@#{field}")
        end
      end
    end
  end
end
