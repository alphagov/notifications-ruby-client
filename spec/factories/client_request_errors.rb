FactoryGirl.define do
  factory :client_request_error,
          class: Notifications::Client::RequestError do
    code '403'
    body do
      {
          'status_code' => 400,
          'errors' => ['error' => 'BadRequest',
                      'message' => 'Invalid token: expired']
      }
    end

    initialize_with do
      new(
        OpenStruct.new(code: code, body: body.to_json)
      )
    end
  end
end
