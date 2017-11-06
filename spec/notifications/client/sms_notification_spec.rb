describe Notifications::Client do
  let(:client) { build :notifications_client }
  let(:uri) { URI.parse(Notifications::Client::PRODUCTION_BASE_URL) }
  let(:mocked_response) {
    attributes_for(:notifications_client_post_sms_response)[:body]
  }

  before do
    stub_request(
      :post,
      "https://#{uri.host}:#{uri.port}/v2/notifications/sms"
    ).to_return(
      body: mocked_response.to_json,
      status: 201,
      headers: { "Content-Type" => "application/json" }
    )
  end

  describe "#send_sms" do
    let!(:sent_sms) {
      client.send_sms(
        phone_number: "+44 7700 900 404",
        template: "f6895ff7-86e0-4d38-80ab-c9525856c3ff"
      )
    }

    it "should send a valid notification" do
      expect(sent_sms).to be_a(
        Notifications::Client::ResponseNotification
      )
    end

    %w(
      id
      content
      uri
      template
    ).each do |field|
      it "expect to include #{field}" do
        expect(
          sent_sms.send(field)
        ).to_not be_nil
      end
    end
  end
end
