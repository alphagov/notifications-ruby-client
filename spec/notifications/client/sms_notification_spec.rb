require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

  include_examples "stub_post_request", "sms"

  describe "#send_sms" do
    let!(:sent_sms) {
      client.send_sms(
        to: "+44 7700 900 404",
        template: "f6895ff7-86e0-4d38-80ab-c9525856c3ff"
      )
    }

    it "should send a valid notification" do
      expect(sent_sms).to be_a(
        Notifications::Client::ResponseNotification
      )
    end

    it "response includes id" do
      expect(sent_sms.id).to eq(
        mocked_response["data"]["notification"]["id"]
      )
    end
  end
end
