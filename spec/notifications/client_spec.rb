require "spec_helper"
require "pry"

describe Notifications::Client do
  it "has a version number" do
    expect(Notifications::Client::VERSION).not_to be nil
  end

  let(:base_url) {
    "https://test.notifications.service.gov.uk"
  }

  let(:jwt_service) {
    "0af431f4-0336-4cae-5e68-968cb0af431f"
  }

  let(:jwt_secret) {
    "b646da86-2648-a663-ce2b-f26489a663cce2b"
  }

  let(:client) {
    Notifications::Client.new(
      base_url,
      jwt_service,
      jwt_secret
    )
  }

  describe "client jwt token" do
    let(:jwt_token) {
      client.speaker.send(:jwt_token)
    }

    let(:decoded_payload) {
      JWT.decode(
        jwt_token,
        jwt_secret,
        true,
        algorithm: "HS256"
      )
    }

    it "should have valid payload" do
      # todo
      expect(
        decoded_payload.first["iss"]
      ).to eq(jwt_service)
    end
  end

  describe "#send_email" do
    let(:mocked_response) {
      {
        data: {
          notification: {
            id: 1
          }
        }
      }
    }

    before do
      uri = URI.parse base_url
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

  describe "#send_sms" do

  end
end
