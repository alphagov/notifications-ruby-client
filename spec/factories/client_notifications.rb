FactoryGirl.define do
  factory :client_notification,
          class: Notifications::Client::Notification do
    initialize_with do
      new(body)
    end

    body do
      {
        "notification" => {
          "status" => "delivered",
          "to" => "07515 987 456",
          "template" => {
            "id" => "5e427b42-4e98-46f3-a047-32c4a87d26bb",
            "name" => "First template",
            "template_type" => "sms"
          },
          "created_at" => "2016-04-26T15:29:36.891512+00:00",
          "updated_at" => "2016-04-26T15:29:38.724808+00:00",
          "sent_at" => "2016-04-26T15:29:37.230976+00:00",
          "job" => {
            "id" => "f9043884-acac-46db-b2ea-f08cd8ec6d67",
            "original_file_name" => "Test run"
          },
          "sent_at" => "2016-04-26T15:29:37.230976+00:00",
          "id" => "f163deaf-2d3f-4ec6-98fc-f23fa511518f",
          "content_char_count" => 490,
          "service" => "5cf87313-fddd-4482-a2ea-48e37320efd1",
          "reference" => "None",
          "sent_by" => "mmg"
        }
      }
    end
  end
end
