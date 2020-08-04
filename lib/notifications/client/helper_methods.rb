require "base64"

module Notifications
  def self.prepare_upload(file, is_csv=false)
    raise ArgumentError.new("File is larger than 2MB") if file.size > Client::MAX_FILE_UPLOAD_SIZE

    { file: Base64.strict_encode64(file.read), is_csv: is_csv }
  end
end
