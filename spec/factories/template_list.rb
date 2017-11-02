FactoryBot.define do
  factory :client_template_collection,
          class: Notifications::Client::TemplateCollection do
    initialize_with do
      new(body)
    end

    body do
      {
        "templates" => 2.times.map {
          attributes_for(:client_template_response)[:body]
        }
      }
    end
  end
end
