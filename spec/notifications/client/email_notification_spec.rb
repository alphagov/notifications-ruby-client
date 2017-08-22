require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

  include_examples "stub_post_email_request", "email"

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
  end
end
