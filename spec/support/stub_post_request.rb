RSpec.shared_examples "stub_post_request" do |kind|
  let(:base_url) {
    attributes_for(:notifications_client)[:base_url]
  }
  let(:uri) {
    URI.parse base_url
  }
  let(:mocked_response) {
    attributes_for :notifications_client_post_response
  }
  before do
    stub_request(
      :post,
      "#{uri.host}:#{uri.port}/notifications/#{kind}"
    ).to_return(
      body: mocked_response.to_json,
      status: 201,
      headers: { "Content-Type" => "application/json" }
    )
  end
end
