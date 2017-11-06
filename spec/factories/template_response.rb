FactoryBot.define do
  factory :client_template_response,
          class: Notifications::Client::Template do
    initialize_with do
      new(body)
    end

    body do
      {
        "id" => "f163deaf-2d3f-4ec6-98fc-f23fa511518f",
        "type" => "email",
        "created_at" => "2016-11-29T11:12:30.12354Z",
        "updated_at" => "2016-11-29T11:12:40.12354Z",
        "created_by" => "jane.doe@gmail.com",
        "body" => "Contents of template ((place_holder))",
        "subject" => "Subject of the email",
        "version" => "2"
      }
    end
  end
end
