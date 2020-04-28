FactoryBot.define do
  factory :notifications_client,
          class: Notifications::Client do
    base_url { nil }
    jwt_secret { "test-key-fa80e418-ff49-445c-a29b-92c04a181207-7aaec57c-2dc9-4d31-8f5c-7225fe79516a" }
    initialize_with do
      new(jwt_secret, base_url)
    end
  end

  factory :notifications_client_combined,
          class: Notifications::Client do
    jwt_secret { "test_key-fa80e418-ff49-445c-a29b-92c04a181207-7aaec57c-2dc9-4d31-8f5c-7225fe79516a" }

    initialize_with do
      new(jwt_secret)
    end
  end

  factory :notifications_client_combined_with_base_url,
          class: Notifications::Client do
    base_url { "http://example.com" }
    jwt_secret { "test_key-fa80e418-ff49-445c-a29b-92c04a181207-7aaec57c-2dc9-4d31-8f5c-7225fe79516a" }

    initialize_with do
      new(jwt_secret, base_url)
    end
  end

  factory :notifications_client_with_invalid_api_key,
          class: Notifications::Client do
    base_url { nil }
    jwt_secret { "test_key-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" }

    initialize_with do
      new(jwt_secret, base_url)
    end
  end

  ##
  # stubbed. response from API
  factory :notifications_client_post_sms_response,
          class: Notifications::Client::ResponseNotification do
    body do
      {
        "id" => "aceed36e-6aee-494c-a09f-88b68904bad6",
        "reference" => nil,
        "content" => {
                        "body" => "Hello we got your application",
                        "from_number" => "40604"
                     },
        "template" => {
                        "id" => "f6895ff7-86e0-4d38-80ab-c9525856c3ff",
                        "version" => 1,
                        "uri" => "/v2/templates/f6895ff7-86e0-4d38-80ab-c9525856c3ff"
                      },
        "uri" => "/notifications/aceed36e-6aee-494c-a09f-88b68904bad6"
      }
    end

    initialize_with do
      new(body)
    end
  end

  ##
  # stubbed. response from API
  factory :notifications_client_post_email_response,
          class: Notifications::Client::ResponseNotification do
    body do
      {
        "id" => "aceed36e-6aee-494c-a09f-88b68904bad6",
        "reference" => nil,
        "content" => {
                        "body" => "Hello we got your application",
                        "subject" => "Application recieved",
                        "from_email" => "40604"
                     },
        "template" => {
                        "id" => "f6895ff7-86e0-4d38-80ab-c9525856c3ff",
                        "version" => 1,
                        "uri" => "/v2/templates/f6895ff7-86e0-4d38-80ab-c9525856c3ff"
                      },
        "uri" => "/notifications/aceed36e-6aee-494c-a09f-88b68904bad6"
      }
    end

    initialize_with do
      new(body)
    end
  end

  ##
  # stubbed. response from API
  factory :notifications_client_post_letter_response,
          class: Notifications::Client::ResponseNotification do
    body do
      {
        "id" => "aceed36e-6aee-494c-a09f-88b68904bad6",
        "reference" => nil,
        "content" => {
                        "body" => "Hello we got your application",
                        "subject" => "Application recieved"
                     },
        "scheduled_for" => nil,
        "template" => {
                        "id" => "f6895ff7-86e0-4d38-80ab-c9525856c3ff",
                        "version" => 1,
                        "uri" => "/v2/templates/f6895ff7-86e0-4d38-80ab-c9525856c3ff"
                      },
        "uri" => "/notifications/aceed36e-6aee-494c-a09f-88b68904bad6"
      }
    end

    initialize_with do
      new(body)
    end
  end
end
