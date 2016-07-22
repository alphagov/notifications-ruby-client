RSpec.shared_examples "stub_post_request" do |kind|
  let(:uri) {
    URI.parse(Notifications::Client::PRODUCTION_BASE_URL)
  }
  let(:mocked_response) {
    attributes_for(:notifications_client_post_response)[:body]
  }
  before do
    stub_request(
      :post,
      "https://#{uri.host}:#{uri.port}/notifications/#{kind}"
    ).to_return(
      body: mocked_response.to_json,
      status: 201,
      headers: { "Content-Type" => "application/json" }
    )
  end
end
