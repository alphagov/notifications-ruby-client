require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

  let(:uri) {
    URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
  }

  describe "get all templates" do
    let(:templates) { client.get_all_templates }

    let(:mocked_response) {
      attributes_for(:client_template_collection)[:body]
    }

    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/templates"
      ).to_return(body: mocked_response.to_json)
    end

    it "expects TemplateCollection" do
      expect(templates).to be_a(
        Notifications::Client::TemplateCollection
      )
    end

    it "collection contains all templates" do
      expect(
        templates.collection.count
      ).to eq(mocked_response["templates"].count)
    end

    it "collection has templates" do
      expect(
        templates.collection.sample
      ).to be_a(Notifications::Client::Template)
    end
  end
end
