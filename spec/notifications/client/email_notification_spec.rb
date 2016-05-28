require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

  let(:base_url) {
    attributes_for(:notifications_client)[:base_url]
  }
  let(:uri) {
    URI.parse base_url
  }

  describe "#send_email" do
    let(:mocked_response) {
      attributes_for :notifications_client_post_response
    }

    before do
      stub_request(
        :post,
        "#{uri.host}:#{uri.port}/notifications/email"
      ).to_return(
        body: mocked_response.to_json,
        status: 201,
        headers: { "Content-Type" => "application/json" }
      )
    end

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
        mocked_response[:data][:notification][:id]
      )
    end
  end
end
