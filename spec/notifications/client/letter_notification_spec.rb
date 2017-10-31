describe Notifications::Client do
  let(:client) { build :notifications_client }
  let(:uri) { URI.parse(Notifications::Client::PRODUCTION_BASE_URL) }
  let(:mocked_response) {
    attributes_for(:notifications_client_post_letter_response)[:body]
  }

  before do
    stub_request(
      :post,
      "https://#{uri.host}:#{uri.port}/v2/notifications/letter"
    ).to_return(
      body: mocked_response.to_json,
      status: 201,
      headers: { "Content-Type" => "application/json" }
    )
  end

  describe "#send_letter" do
    let!(:sent_letter) {
      client.send_letter(
        template_id: "f6895ff7-86e0-4d38-80ab-c9525856c3ff",
        personalisation: {
          address_line_1: "The Occupier",
          address_line_2: "123 High Street",
          postcode: "SW14 6BH"
        }
      )
    }

    it "should send a valid notification" do
      expect(sent_letter).to be_a(
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
          sent_letter.send(field)
        ).to_not be_nil
      end
    end
  end
end
