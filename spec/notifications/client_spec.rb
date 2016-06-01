require "spec_helper"

describe Notifications::Client do
  it "has a version number" do
    expect(Notifications::Client::VERSION).not_to be nil
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
