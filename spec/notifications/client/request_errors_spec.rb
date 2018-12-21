describe Notifications::Client do
  let(:client) { build :notifications_client }
  let(:uri) { URI.parse(Notifications::Client::PRODUCTION_BASE_URL) }

  def stub_error_request(code, body: nil)
    url = "https://#{uri.host}:#{uri.port}/v2/notifications/1"
    body = attributes_for(:client_request_error)[:body] unless body
    stub_request(:get, url).to_return(status: code, body: body.to_json)
  end

  def expect_error(error_class = Notifications::Client::RequestError)
    expect { client.get_notification("1") }.to raise_error(error_class)
  end

  describe "authorisation error" do
    before { stub_error_request(403) }

    it "raises exception" do
      expect_error
    end
  end

  describe "server error" do
    it "raises a Notifications::Client::RequestError" do
      stub_error_request(503, body: {
        'status_code' => 503,
        'errors' => ['error' => 'BadRequestError', 'message' => 'App error']
      })

      expect_error
    end
  end
end
