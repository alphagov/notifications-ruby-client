require "notifications/client/version"
require "notifications/client/speaker"
require "notifications/client/notification"
require "notifications/client/response_notification"
require "notifications/client/notifications_collection"
require "notifications/client/response_template"
require "forwardable"

module Notifications
  class Client
    attr_reader :speaker

    PRODUCTION_BASE_URL = "https://api.notifications.service.gov.uk".freeze

    extend Forwardable
    def_delegators :speaker, :service_id, :secret_token, :base_url, :base_url=

    ##
    # @see Notifications::Client::Speaker#initialize
    def initialize(*args)
      @speaker = Speaker.new(*args)
    end

    ##
    # @see Notifications::Client::Speaker#post
    # @return [ResponseNotification]
    def send_email(args)
      ResponseNotification.new(
        speaker.post("email", args)
      )
    end

    ##
    # @see Notifications::Client::Speaker#post
    # @return [ResponseNotification]
    def send_sms(args)
      ResponseNotification.new(
        speaker.post("sms", args)
      )
    end

    ##
    # @param id [String]
    # @see Notifications::Client::Speaker#get
    # @return [Notification]
    def get_notification(id)
      Notification.new(
        speaker.get(id)
      )
    end

    ##
    # @param options [Hash]
    # @option options [String] :template_type
    #   sms or email
    # @option options [String] :status
    #   sending, delivered, permanently failed,
    #   temporarily failed, or technical failure
    # @option options [String] :reference
    #   your reference for the notification
    # @option options [String] :olderThanId
    #   notification id to return notificaitons that are older than this id.
    # @see Notifications::Client::Speaker#get
    # @return [NotificationsCollection]
    def get_notifications(options = {})
      NotificationsCollection.new(
        speaker.get(nil, options)
      )
    end

    ##
    # @param id [String]
    # @return [Template]
    def get_template_by_id(id, options = {})
      Template.new(
        speaker.get_template(id, options)
      )
    end
  end
end
