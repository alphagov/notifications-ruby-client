describe Notifications::Client do
  let(:client) { build :notifications_client }

  let(:uri) {
    URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
  }

  describe "get a template by id and version" do
    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/template/#{id}/version/#{version}"
      ).to_return(body: mocked_response.to_json)
    end

    let(:id) {
      "1"
    }
    let(:version) {
      "1"
    }
    let!(:template) {
      client.get_template_version(id, version)
    }

    let(:mocked_response) {
      attributes_for(:client_template_response)[:body]
    }

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

    it "hits the correct API endpoint" do
      expect(WebMock).to have_requested(:get, "https://#{uri.host}:#{uri.port}/v2/template/#{id}/version/#{version}")
    end
  end
end
