FactoryGirl.define do
  factory :client_notifications_collection,
          class: Notifications::Client::NotificationsCollection do
    initialize_with do
      new(body)
    end

    body do
      {
        "links" => {
          "current" => "/v2/notifications?page=3&template_type=sms&status=delivered",
          "next" => "/v2/notifications?page=3&template_type=sms&status=delivered"
        },
        "notifications" => 2.times.map {
          attributes_for(:client_notification)[:body]
        }
      }
    end
  end
end
