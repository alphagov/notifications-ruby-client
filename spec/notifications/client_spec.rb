require "spec_helper"

describe Notifications::Client do
  it "has a version number" do
    expect(Notifications::Client::VERSION).not_to be nil
  end

  describe "with combined API key" do
    let(:client) { build :notifications_client_combined }

    it "should extract service ID" do
      expect(
        client.service_id
      ).to eq("fa80e418-ff49-445c-a29b-92c04a181207")
    end

    it "should extract secret" do
      expect(
        client.secret_token
      ).to eq("7aaec57c-2dc9-4d31-8f5c-7225fe79516a")
    end

    it "should have use default base URL" do
      expect(
        client.base_url
      ).to eq(Notifications::Client::PRODUCTION_BASE_URL)
    end
  end


  describe "with combined API key and non-default base URL" do
    let(:client) { build :notifications_client_combined_with_base_url }

    it "should extract service ID" do
      expect(
        client.service_id
      ).to eq("fa80e418-ff49-445c-a29b-92c04a181207")
    end

    it "should extract secret" do
      expect(
        client.secret_token
      ).to eq("7aaec57c-2dc9-4d31-8f5c-7225fe79516a")
    end

    it "should use custom base URL" do
      expect(
        client.base_url
      ).to eq("http://example.com")
    end
  end

  describe "#base_url" do
    describe "default base url" do
      let(:client) { build :notifications_client }

      it {
        expect(client.base_url).to eq(
          Notifications::Client::PRODUCTION_BASE_URL
        )
      }
    end

    describe "set base url" do
      let(:new_url) {
        "https://test.notifications.service.gov.uk"
      }

      let(:client) {
        build :notifications_client, base_url: new_url
      }

      it {
        expect(client.base_url).to eq(new_url)
      }
    end
  end
end
