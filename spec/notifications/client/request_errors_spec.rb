describe Notifications::Client do
  let(:client) { build :notifications_client }
  let(:uri) { URI.parse(Notifications::Client::PRODUCTION_BASE_URL) }

  def stub_error_request(code, body: nil)
    url = "https://#{uri.host}:#{uri.port}/v2/notifications/1"
    body = attributes_for(:client_request_error)[:body] unless body
    stub_request(:get, url).to_return(status: code, body: body.to_json)
  end

  def expect_error(error_class = Notifications::Client::RequestError, message = nil)
    expect { client.get_notification("1") }.to raise_error(error_class, message)
  end

  shared_examples "raises an error" do |error_class, message|
    it "should raise a #{error_class}" do
      expect_error(error_class, message)
    end

    it "should be a subclass of Notifications::Client::RequestError" do
      expect_error
    end
  end

  describe "bad request error" do
    before { stub_error_request(400) }
    include_examples "raises an error", Notifications::Client::BadRequestError
  end

  describe "authorisation error" do
    before { stub_error_request(403) }
    include_examples "raises an error", Notifications::Client::AuthError
  end

  describe "not found error" do
    before { stub_error_request(404) }
    include_examples "raises an error", Notifications::Client::NotFoundError
  end

  describe "rate limit error" do
    before { stub_error_request(429) }
    include_examples "raises an error", Notifications::Client::RateLimitError
  end

  describe "other client error" do
    before { stub_error_request(487) }
    include_examples "raises an error", Notifications::Client::ClientError
  end

  describe "server error" do
    before do
      stub_error_request(503, body: {
        'status_code' => 503,
        'errors' => ['error' => 'BadRequestError', 'message' => 'App error']
      })
    end

    include_examples "raises an error", Notifications::Client::ServerError, "BadRequestError: App error"
  end

  describe "#message" do
    before do
      stub_error_request(401, body: {
        'status_code' => 401,
        'errors' => ['error' => 'BadRequestError', 'message' => 'Can’t send to this recipient using a team-only API key']
      })
    end

    it "returns the message" do
      expect { client.get_notification('1') }.to raise_error do |error|
        expect(error.to_s).to eql('BadRequestError: Can’t send to this recipient using a team-only API key')
        expect(error.message).to eql('BadRequestError: Can’t send to this recipient using a team-only API key')
      end
    end
  end
end
