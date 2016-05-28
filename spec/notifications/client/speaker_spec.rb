require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

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
end
