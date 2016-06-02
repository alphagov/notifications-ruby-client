FactoryGirl.define do
  factory :client_notifications_collection,
          class: Notifications::Client::NotificationsCollection do
    initialize_with do
      new(body)
    end

    body do
      {
        "total" => 162,
        "page_size" => 50,
        "links" => {
          "last" => "/notifications?page=3&template_type=sms&status=delivered",
          "next" => "/notifications?page=3&template_type=sms&status=delivered"
        },
        "notifications" => 2.times.map {
          attributes_for(:client_notification)[:body]["notification"]
        }
      }
    end
  end
end
