require "base64"

module Notifications
  def self.prepare_upload(file)
    raise ArgumentError.new("File is larger than 2MB") if file.size > Client::MAX_FILE_UPLOAD_SIZE

    { file: Base64.strict_encode64(file.read) }
  end
end
