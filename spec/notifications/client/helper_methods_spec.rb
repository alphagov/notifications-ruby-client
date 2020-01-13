require "base64"

describe Notifications do
  describe ".prepare_upload" do
    it "encodes a File object" do
      File.open('spec/test_files/test_pdf.pdf', 'rb') do |f|
        encoded_content = Base64.strict_encode64(f.read)
        f.rewind

        result = Notifications.prepare_upload(f)
        f.rewind

        expect(result).to eq(file: encoded_content)
        expect(Base64.strict_decode64(encoded_content)).to eq(f.read)
      end
    end

    it "encodes a StringIO object" do
      input_string = StringIO.new("My document to send")
      expect(Notifications.prepare_upload(input_string)).to eq(file: "TXkgZG9jdW1lbnQgdG8gc2VuZA==")
    end

    it "raises an error when the file size is too large" do
      File.open('spec/test_files/test_pdf.pdf', 'rb') do |file|
        allow(file).to receive(:size).and_return(Notifications::Client::MAX_FILE_UPLOAD_SIZE + 1)

        expect { Notifications.prepare_upload(file) }.to raise_error(ArgumentError, "File is larger than 2MB")
      end
    end
  end
end
