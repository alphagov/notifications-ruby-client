describe Notifications::Client do
  let(:client) { build :notifications_client }

  describe "client jwt token" do
    let(:jwt_token) {
      client.speaker.send(:jwt_token)
    }
    let(:secret) { "7aaec57c-2dc9-4d31-8f5c-7225fe79516a" }
    let(:service_id) { "fa80e418-ff49-445c-a29b-92c04a181207" }


    let(:decoded_payload) {
      JWT.decode(
        jwt_token,
        secret,
        true,
        algorithm: "HS256"
      )
    }

    it "should have valid payload" do
      expect(
        decoded_payload.first["iss"]
      ).to eq(service_id)
    end
  end
end
