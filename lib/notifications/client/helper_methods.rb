require "base64"

module Notifications
  def self.prepare_upload(file, is_csv=false, confirm_email_before_download: nil, retention_period: nil)
    raise ArgumentError.new("File is larger than 2MB") if file.size > Client::MAX_FILE_UPLOAD_SIZE

    data = { file: Base64.strict_encode64(file.read), is_csv: is_csv }

    data[:confirm_email_before_download] = confirm_email_before_download
    data[:retention_period] = retention_period

    data
  end
end
