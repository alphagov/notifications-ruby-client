module Notifications
  class Client
    class ReceivedTextCollection
      attr_reader :links, :collection

      def initialize(response)
        @links = response["links"]
        @collection = collection_from(response["received_text_messages"])
      end

      def collection_from(received_texts)
        received_texts.map do |received_text|
          ReceivedText.new(received_text)
        end
      end
    end
  end
end
