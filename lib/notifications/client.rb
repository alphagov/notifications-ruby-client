require "notifications/client/version"
require "notifications/client/speaker"
require "notifications/client/response_notification"

module Notifications
  class Client
    attr_reader :speaker

    ##
    # @see Notifications::Client::Speaker#initialize
    def initialize(*args)
      @speaker = Speaker.new(*args)
    end

    ##
    # @see Notifications::Client::Speaker#post
    def send_email(args)
      response = speaker.post(
        "email",
        args
      )
      ResponseNotification.new response
    end
  end
end
