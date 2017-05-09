require "spec_helper"

describe Notifications::Client do
  let(:client) { build :notifications_client }

  let(:uri) {
    URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
  }

  describe "get a template by id" do
    let(:id) {
      "1"
    }

    let(:template) {
      client.get_template_by_id(id)
    }

    let(:mocked_response) {
      attributes_for(:client_template_response)[:body]
    }

    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/template/#{id}"
      ).to_return(body: mocked_response.to_json)
    end

    it "expects template" do
      expect(template).to be_a(
        Notifications::Client::Template
      )
    end

    %w(
      id
      type
      body
      created_at
      updated_at
      created_by
      subject
      version
    ).each do |field|
      it "expect to include #{field}" do
        expect(
          template.send(field)
        ).to_not be_nil
      end
    end
  end
end
