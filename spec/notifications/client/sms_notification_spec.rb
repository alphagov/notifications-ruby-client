require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

  include_examples "stub_post_sms_request", "sms"

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
