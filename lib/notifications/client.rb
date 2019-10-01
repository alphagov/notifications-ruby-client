require_relative "client/version"
require_relative "client/speaker"
require_relative "client/notification"
require_relative "client/response_notification"
require_relative "client/response_precompiled_letter"
require_relative "client/notifications_collection"
require_relative "client/received_text"
require_relative "client/received_text_collection"
require_relative "client/response_template"
require_relative "client/template_collection"
require_relative "client/template_preview"
require_relative "client/uuid_validator"
require_relative "client/helper_methods"
require "forwardable"

module Notifications
  class Client
    attr_reader :speaker

    PRODUCTION_BASE_URL = "https://api.notifications.service.gov.uk".freeze
    MAX_FILE_UPLOAD_SIZE = 2 * 1024 * 1024 # 2MB limit on uploaded documents

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
    # @see Notifications::Client::Speaker#post
    # @return [ResponseNotification]
    def send_letter(args)
      ResponseNotification.new(
        speaker.post("letter", args)
      )
    end

    ##
    # @param reference [String]
    # @param pdf_file [File]
    # @see Notifications::Client::Speaker#post_precompiled_letter
    # @return [ResponsePrecompiledLetter]
    def send_precompiled_letter(reference, pdf_file, postage = nil)
      ResponsePrecompiledLetter.new(
        speaker.post_precompiled_letter(reference, pdf_file, postage)
      )
    end

    ##
    # @param id [String]
    # @see Notifications::Client::Speaker#get
    # @return [String]
    def get_pdf_for_letter(id)
      speaker.get_pdf_for_letter(id)
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
    # @option options [String] :older_than
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
      path = "/v2/template/" << id
      Template.new(
        speaker.get_with_url(path, options)
      )
    end

    ##
    # @param id [String]
    # @param version [int]
    # @return [Template]
    def get_template_version(id, version, options = {})
      path = "/v2/template/" << id << "/version/" << version.to_s
      Template.new(
        speaker.get_with_url(path, options)
      )
    end

    ##
    # @option options [String] :type
    #   email, sms, letter
    # @return [TemplateCollection]
    def get_all_templates(options = {})
      path = "/v2/templates"
      TemplateCollection.new(
        speaker.get_with_url(path, options)
      )
    end

    ##
    # @param options [String]
    # @option personalisation [Hash]
    # @return [TemplatePreview]
    def generate_template_preview(id, options = {})
      path = "/v2/template/" << id << "/preview"
      TemplatePreview.new(
        speaker.post_with_url(path, options)
      )
    end

    ##
    # @option options [String] :older_than
    #   received text id to return received texts that are older than this id.
    # @return [ReceivedTextCollection]
    def get_received_texts(options = {})
      path = "/v2/received-text-messages"
      ReceivedTextCollection.new(
        speaker.get_with_url(path, options)
      )
    end
  end
end
