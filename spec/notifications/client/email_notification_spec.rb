describe Notifications::Client do
  let(:client) { build :notifications_client }
  let(:uri) { URI.parse(Notifications::Client::PRODUCTION_BASE_URL) }
  let(:mocked_response) {
    attributes_for(:notifications_client_post_email_response)[:body]
  }

  before do
    stub_request(
      :post,
      "https://#{uri.host}:#{uri.port}/v2/notifications/email"
    ).to_return(
      body: mocked_response.to_json,
      status: 201,
      headers: { "Content-Type" => "application/json" }
    )
  end

  describe "#send_email" do
    let!(:sent_email) {
      client.send_email(
        email_address: "email@gov.uk",
        template_id: "f6895ff7-86e0-4d38-80ab-c9525856c3ff"
      )
    }

    it "should send valid notification" do
      expect(sent_email).to be_a(
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
          sent_email.send(field)
        ).to_not be_nil
      end
    end

    it "hits the correct API endpoint" do
      expect(WebMock).to have_requested(:post, "https://#{uri.host}:#{uri.port}/v2/notifications/email").
        with(body: { email_address: "email@gov.uk", template_id: "f6895ff7-86e0-4d38-80ab-c9525856c3ff" })
    end
  end
end
