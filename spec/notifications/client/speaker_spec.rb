require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

  describe "client jwt token" do
    let(:jwt_token) {
      client.speaker.send(:jwt_token)
    }
    let(:jwt_secret) {
      attributes_for(:notifications_client)[:jwt_secret]
    }
    let(:jwt_service) {
      attributes_for(:notifications_client)[:jwt_service]
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
      expect(
        decoded_payload.first["iss"]
      ).to eq(jwt_service)
    end
  end
end
