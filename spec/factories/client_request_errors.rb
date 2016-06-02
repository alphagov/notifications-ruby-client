FactoryGirl.define do
  factory :client_request_error,
          class: Notifications::Client::RequestError do
    code "403"
    body do
      {
        "result" => "error",
        "message" => "Invalid token: expired"
      }
    end

    initialize_with do
      new(
        OpenStruct.new(code: code, body: body.to_json)
      )
    end
  end
end
