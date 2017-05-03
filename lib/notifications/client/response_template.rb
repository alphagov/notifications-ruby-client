module Notifications
  class Client
    class Template
      FIELDS = [
        :id,
        :type,
        :created_at,
        :updated_at,
        :created_by,
        :version,
        :body,
        :subject
      ].freeze

            attr_reader(*FIELDS)

            def initialize(notification)

              FIELDS.each do |field|
                  instance_variable_set(:"@#{field}", notification.fetch(field.to_s, nil)
                  )
              end
            end

            [
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
