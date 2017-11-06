describe Notifications::Client do
  let(:client) { build :notifications_client }

  let(:uri) {
    URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
  }

  describe "get a notification by id" do
    let(:id) {
      "1"
    }

    let(:notification) {
      client.get_notification(id)
    }

    let(:mocked_response) {
      attributes_for(:client_notification)[:body]
    }

    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/notifications/#{id}"
      ).to_return(body: mocked_response.to_json)
    end

    it "expects notification" do
      expect(notification).to be_a(
        Notifications::Client::Notification
      )
    end

    %w(
      id
      reference
      phone_number
      type
      status
      template
      body
      created_at
      sent_at
      completed_at
    ).each do |field|
      it "expect to include #{field}" do
        expect(
          notification.send(field)
        ).to_not be_nil
      end
    end
  end
end
