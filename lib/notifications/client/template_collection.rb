module Notifications
  class Client
    class TemplateCollection
      attr_reader :collection
      def initialize(response)
        @collection = collection_from(response["templates"])
      end

      def collection_from(templates)
        templates.map do |template|
          Template.new(template)
        end
      end
    end
  end
end
