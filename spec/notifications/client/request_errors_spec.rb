describe Notifications::Client do
  let(:client) { build :notifications_client }
  let(:uri) { URI.parse(Notifications::Client::PRODUCTION_BASE_URL) }

  describe "authorisation error" do
    let(:error_response) {
      attributes_for(:client_request_error)[:body]
    }

    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/notifications/1"
      ).to_return(
        status: 403,
        body: error_response.to_json
      )
    end

    it "raises exception" do
      expect {
        client.get_notification("1")
      }.to raise_error(Notifications::Client::RequestError)
    end
  end

  describe "server error" do
    it "raises a Notifications::Client::RequestError" do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/notifications/1"
      ).to_return(
        status: 503,
        body: {
                'status_code' => 503,
                'errors' => ['error' => 'BadRequestError', 'message' => 'App error']
              }.to_json
      )

      expect {
        client.get_notification("1")
      }.to raise_error(Notifications::Client::RequestError)
    end
  end
end
