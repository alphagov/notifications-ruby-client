describe Notifications::Client do
  let(:client) { build :notifications_client }

  let(:uri) {
    URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
  }

  describe "get a pdf for a letter notification" do
    before do
      stub_request(
        :get,
        "https://#{uri.host}:#{uri.port}/v2/notifications/#{id}/pdf"
      ).to_return(body: mocked_response)
    end

    let(:id) {
      "1"
    }

    let!(:pdf) {
      client.get_pdf_for_letter(id)
    }

    let(:mocked_response) {
      'foobar'
    }

    it "expects pdf to be returned" do
      expect(pdf).to equal(mocked_response)
    end

    it "hits the correct API endpoint" do
      expect(WebMock).to have_requested(:get, "https://#{uri.host}:#{uri.port}/v2/notifications/#{id}/pdf")
    end
  end
end
