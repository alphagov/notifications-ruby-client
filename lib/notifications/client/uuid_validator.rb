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

    def self.validate!(uuid)
      return if new(uuid).valid?
      raise ArgumentError, "#{uuid.inspect} is not a valid uuid"
    end
  end
end

