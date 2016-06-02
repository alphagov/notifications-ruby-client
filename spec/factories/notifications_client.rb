FactoryGirl.define do
  factory :notifications_client,
          class: Notifications::Client do
    base_url { nil }
    jwt_service "0af431f4-0336-4cae-5e68-968cb0af431f"
    jwt_secret "b646da86-2648-a663-ce2b-f26489a663cce2b"

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
