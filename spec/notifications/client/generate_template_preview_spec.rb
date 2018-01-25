describe Notifications::Client do
  let(:client) { build :notifications_client }

  let(:uri) {
    URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
  }

  describe "generate template preview" do
    before do
      stub_request(
        :post,
        "https://#{uri.host}:#{uri.port}/v2/template/#{id}/preview"
      ).to_return(body: mocked_response.to_json)
    end

    let(:id) {
      "1"
    }
    let(:personalisation) {
      { name: "Mr Big Nose" }
    }

    let!(:template_preview) {
      client.generate_template_preview(id, personalisation)
    }

    let(:mocked_response) {
      attributes_for(:client_template_preview)[:body]
    }

    it "expects template preview" do
      expect(template_preview).to be_a(
        Notifications::Client::TemplatePreview
      )
    end

    %w(
      id
      body
      subject
      version
    ).each do |field|
      it "expect to include #{field}" do
        expect(
          template_preview.send(field)
        ).to_not be_nil
      end
    end

    it "hits the correct API endpoint" do
      expect(WebMock).to have_requested(:post, "https://#{uri.host}:#{uri.port}/v2/template/#{id}/preview").
        with(body: { name: "Mr Big Nose" })
    end
  end
end
