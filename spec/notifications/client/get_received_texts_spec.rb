describe Notifications::Client do
  let(:client) { build :notifications_client }

  let(:uri) {
    URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
  }

  describe "get received texts requests" do
    it "hits the received text message endpoint without older_than" do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/received-text-messages"
      ).to_return(body: {"received_text_messages": []}.to_json)

      client.get_received_texts
      expect(WebMock).to have_requested(:get, "https://#{uri.host}:#{uri.port}/v2/received-text-messages")
    end

    it "hits the received text message endpoint with older_than" do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/received-text-messages?older_than=received-text-id"
      ).to_return(body: {"received_text_messages": []}.to_json)

      client.get_received_texts(older_than: "received-text-id")
      expect(WebMock).to have_requested(:get, "https://#{uri.host}:#{uri.port}/v2/received-text-messages").
        with(query: { "older_than" => "received-text-id" })
    end
  end
end
