module Notifications
  class UuidValidator
    HEX = /[0-9a-f]/
    REGEX = /^#{HEX}{8}-#{HEX}{4}-#{HEX}{4}-#{HEX}{4}-#{HEX}{12}$/

    attr_accessor :uuid

    def initialize(uuid)
      self.uuid = uuid
    end

    def valid?
      !!(uuid && uuid.match(REGEX))
    end

    def self.validate!(uuid, contextual_message = nil)
      return if new(uuid).valid?

      message = "#{uuid.inspect} is not a valid uuid"
      message += "\n#{contextual_message}" if contextual_message

      raise ArgumentError, message
    end
  end
end
