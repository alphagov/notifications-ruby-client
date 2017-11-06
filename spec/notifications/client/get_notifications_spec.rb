describe Notifications::Client do
  let(:client) { build :notifications_client }

  let(:uri) {
    URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
  }

  describe "get all notifications" do
    let(:notifications) {
      client.get_notifications
    }

    let(:mocked_response) {
      attributes_for(:client_notifications_collection)[:body]
    }

    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/notifications"
      ).to_return(body: mocked_response.to_json)
    end

    it "collection contains all notifications" do
      expect(
        notifications.collection.count
      ).to eq(mocked_response["notifications"].count)
    end

    it "collection has notifications" do
      expect(
        notifications.collection.sample
      ).to be_a(Notifications::Client::Notification)
    end
  end

  describe "get notifications by query" do
    let(:options) {
      {
        "template_type" => "sms",
        "status"        => "delivered"
      }
    }

    let(:notifications) {
      client.get_notifications(
        options
      )
    }

    let(:mocked_response) {
      attributes_for(
        :client_notifications_collection
      )[:body].merge(options)
    }

    let(:request_path) {
      URI.encode_www_form(options)
    }

    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/notifications?#{request_path}"
      ).to_return(body: mocked_response.to_json)
    end

    it "expect to request with right parameters" do
      notifications
      expect(WebMock).to have_requested(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/notifications"
      ).with(query: options)
    end

    it "expects notifications collection" do
      expect(notifications).to be_a(
        Notifications::Client::NotificationsCollection
      )
    end

    %w(links).each do |field|
      it "should contain service #{field}" do
        expect(
          notifications.send(field)
        ).to eq(mocked_response.fetch(field))
      end
    end
  end
end
