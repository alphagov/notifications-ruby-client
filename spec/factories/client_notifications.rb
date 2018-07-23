FactoryBot.define do
  factory :client_notification,
          class: Notifications::Client::Notification do
    initialize_with do
      new(body)
    end

    body do
      {
        "id" => "f163deaf-2d3f-4ec6-98fc-f23fa511518f",
        "reference" => "your_reference_string",
        "phone_number" => "07515 987 456",
        "email_address" => nil,
        "line_1" => nil,
        "line_2" => nil,
        "line_3" => nil,
        "line_4" => nil,
        "line_5" => nil,
        "line_6" => nil,
        "postcode" => nil,
        "type" => "sms",
        "status" => "delivered",
        "template" =>
            {
              "id" => "5e427b42-4e98-46f3-a047-32c4a87d26bb",
              "uri" => "/v2/templates/5e427b42-4e98-46f3-a047-32c4a87d26bb",
              "version" => 1
            },
        "body" => "Body of the message",
        "subject" => nil,
        "created_at" => "2016-11-29T11:12:30.12354Z",
        "sent_at" => "2016-11-29T11:12:40.12354Z",
        "completed_at" => "2016-11-29T11:12:52.12354Z",
        "created_by_name" => "A. Sender",
      }
    end
  end
end
