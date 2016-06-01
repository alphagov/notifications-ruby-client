require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

  include_examples "stub_post_request", "email"

  describe "#send_email" do
    let!(:sent_email) {
      client.send_email(
        to: "email@gov.uk",
        template: "f6895ff7-86e0-4d38-80ab-c9525856c3ff"
      )
    }

    it "should send valid notification" do
      expect(sent_email).to be_a(
        Notifications::Client::ResponseNotification
      )
    end

    it "response includes id" do
      expect(sent_email.id).to eq(
        mocked_response["data"]["notification"]["id"]
      )
    end
  end
end
