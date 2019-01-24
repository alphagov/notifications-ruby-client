require "stringio"

describe Notifications::Client do
  let(:client) { build :notifications_client }
  let(:uri) { URI.parse(Notifications::Client::PRODUCTION_BASE_URL) }

  describe "#send_precompiled_letter" do
    before do
      stub_request(:post, "https://#{uri.host}/v2/notifications/letter").
        to_return(
          body: { "id" => "12345", "reference" => "my letter", "postage" => "first" }.to_json,
          status: 201,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "hits the correct API endpoint with an encoded File object" do
      pdf_file = File.open('spec/test_files/test_pdf.pdf', 'rb')
      encoded_content = Base64.strict_encode64(pdf_file.read)
      pdf_file.rewind

      client.send_precompiled_letter('12345', pdf_file)
      pdf_file.close

      expect(WebMock).to have_requested(:post, "https://#{uri.host}/v2/notifications/letter").
        with(body: { reference: "12345", content: encoded_content })
    end

    it "hits the correct API endpoint with an encoded StringIO object" do
      input_string = StringIO.new("My precompiled letter")
      encoded_content = Base64.strict_encode64(input_string.read)
      input_string.rewind

      client.send_precompiled_letter('12345', input_string)

      expect(WebMock).to have_requested(:post, "https://#{uri.host}/v2/notifications/letter").
        with(body: { reference: "12345", content: encoded_content })
    end

    it "hits the correct API endpoint with postage" do
      input_string = StringIO.new("My precompiled letter")
      encoded_content = Base64.strict_encode64(input_string.read)
      input_string.rewind

      client.send_precompiled_letter('12345', input_string, 'first')

      expect(WebMock).to have_requested(:post, "https://#{uri.host}/v2/notifications/letter").
        with(body: { reference: "12345", content: encoded_content, postage: 'first' })
    end

    it "returns a ResponsePrecompiledLetter with an id, postage and reference" do
      response = File.open('spec/test_files/test_pdf.pdf', 'rb') do |file|
        client.send_precompiled_letter('my letter', file, 'first')
      end

      expect(response).to be_a(Notifications::Client::ResponsePrecompiledLetter)
      expect(response.id).to eq('12345')
      expect(response.reference).to eq('my letter')
      expect(response.postage).to eq('first')
    end
  end
end
