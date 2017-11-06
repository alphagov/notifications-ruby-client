FactoryBot.define do
  factory :client_template_preview,
          class: Notifications::Client::TemplatePreview do
    initialize_with do
      new(body)
    end

    body do
      {
        "id" => "f163deaf-2d3f-4ec6-98fc-f23fa511518f",
        "body" => "Contents of template Mr Big Nose",
        "subject" => "Subject of the email",
        "version" => "2",
        "type" => "email"
      }
    end
  end
end
