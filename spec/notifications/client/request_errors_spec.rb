require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

  describe "authorisation error" do
    let(:error_response) {
      attributes_for(:client_request_error)[:body]
    }

    let(:uri) {
      URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
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
end
