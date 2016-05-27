require "spec_helper"

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
    let(:decoded_payload) {
      JWT.decode(
        client.send(:jwt_token),
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
    it "should send valid notification" do

    end

    it "response includes id" do
      # todo
    end
  end

  describe "#send_sms" do

  end
end
