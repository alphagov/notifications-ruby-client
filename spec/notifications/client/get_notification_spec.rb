describe Notifications::Client do
  let(:client) { build :notifications_client }
  let(:uri) { URI.parse(Notifications::Client::PRODUCTION_BASE_URL) }

  describe "get a notification by id" do
    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/notifications/#{id}"
      ).to_return(body: mocked_response.to_json)
    end

    let(:id) { "1" }
    let!(:notification) { client.get_notification(id) }
    let(:mocked_response) { attributes_for(:client_notification)[:body] }

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
      created_by_name
      cost_in_pounds
      is_cost_data_ready
      cost_details
    ).each do |field|
      it "expect to include #{field}" do
        expect(
          notification.send(field)
        ).to_not be_nil
      end
    end

    it "parses the time correctly" do
      expect(notification.created_at.to_s).to eq("2016-11-29 11:12:30 UTC")
    end

    it "hits the correct API endpoint" do
      expect(WebMock).to have_requested(:get, "https://#{uri.host}:#{uri.port}/v2/notifications/#{id}")
    end
  end
end
