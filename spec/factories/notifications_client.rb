FactoryGirl.define do
  factory :notifications_client,
          class: Notifications::Client do
    base_url { nil }
    jwt_service "fa80e418-ff49-445c-a29b-92c04a181207"
    jwt_secret "7aaec57c-2dc9-4d31-8f5c-7225fe79516a"

    initialize_with do
      new(jwt_service, jwt_secret, base_url)
    end
  end

  ##
  # stubbed. response from API
  factory :notifications_client_post_response,
          class: Notifications::Client::ResponseNotification do
    body do
      {
        "data" => {
          "notification" => {
            "id" => 1
          }
        }
      }
    end

    initialize_with do
      new(body)
    end
  end
end
