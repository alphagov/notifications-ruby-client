describe Notifications::Client do
  let(:client) { build :notifications_client }

  let(:uri) {
    URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
  }

  let(:mocked_response) {
    attributes_for(:client_template_collection)[:body]
  }

  describe "get all templates" do
    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/templates"
      ).to_return(body: mocked_response.to_json)
    end

    let!(:templates) { client.get_all_templates }

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

    it "hits the correct API endpoint with no parameters" do
      expect(WebMock).to have_requested(:get, "https://#{uri.host}:#{uri.port}/v2/templates")
    end
  end

  describe "get templates by query" do
    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/templates?template_type=sms"
      ).to_return(body: mocked_response.to_json)
    end

    it "hits the correct API endpoint when filtering by template type" do
      args = { template_type: "sms" }

      client.get_all_templates(args)

      expect(WebMock).to have_requested(:get, "https://#{uri.host}:#{uri.port}/v2/templates").with(query: args)
    end
  end
end
