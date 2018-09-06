describe Notifications::Client do
  let(:client) { build :notifications_client }
  let(:uri) { URI.parse(Notifications::Client::PRODUCTION_BASE_URL) }

  describe "#send_precompiled_letter" do
    before do
      stub_request(:post, "https://#{uri.host}/v2/notifications/letter").
        to_return(
          body: { "id" => "12345", "reference" => "my letter" }.to_json,
          status: 201,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "hits the correct API endpoint with the encoded PDF file" do
      pdf_file = File.open('spec/test_files/test_pdf.pdf', 'rb')
      encoded_content = Base64.strict_encode64(pdf_file.read)
      pdf_file.rewind

      client.send_precompiled_letter('12345', pdf_file)
      pdf_file.close

      expect(WebMock).to have_requested(:post, "https://#{uri.host}/v2/notifications/letter").
        with(body: { reference: "12345", content: encoded_content })
    end

    it "returns a ResponseNotification with an id and reference" do
      response = File.open('spec/test_files/test_pdf.pdf', 'rb') do |file|
        client.send_precompiled_letter('my letter', file)
      end

      expect(response).to be_a(Notifications::Client::ResponseNotification)
      expect(response.id).to eq('12345')
      expect(response.reference).to eq('my letter')

      expect(response.uri).to be_nil
      expect(response.content).to be_nil
      expect(response.template).to be_nil
    end
  end
end
