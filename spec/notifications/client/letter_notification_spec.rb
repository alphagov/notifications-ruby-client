require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

  include_examples "stub_post_letter_request", "letter"

  describe "#send_letter" do
    let!(:sent_letter) {
      client.send_letter(
        template_id: "f6895ff7-86e0-4d38-80ab-c9525856c3ff",
        personalisation: {
          "address_line_1": "The Occupier",
          "address_line_2": "123 High Street",
          "postcode": "SW14 6BH"
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
