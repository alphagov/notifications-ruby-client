FactoryGirl.define do
  factory :notifications_client,
          class: Notifications::Client do
    base_url "https://test.notifications.service.gov.uk"
    jwt_service "0af431f4-0336-4cae-5e68-968cb0af431f"
    jwt_secret "b646da86-2648-a663-ce2b-f26489a663cce2b"

    initialize_with do
      new(
        base_url,
        jwt_service,
        jwt_secret
      )
    end
  end

  factory :notifications_client_post_response,
          class: Object do #stubbed
    data do
      {
        notification: {
          id: 1
        }
      }
    end
  end
end
