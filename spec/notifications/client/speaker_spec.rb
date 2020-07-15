describe Notifications::Client do
  let(:client) { build :notifications_client }

  describe "client jwt token" do
    let(:jwt_token) {
      client.speaker.send(:jwt_token)
    }
    let(:secret) { "7aaec57c-2dc9-4d31-8f5c-7225fe79516a" }
    let(:service_id) { "fa80e418-ff49-445c-a29b-92c04a181207" }


    let(:decoded_payload) {
      JWT.decode(
        jwt_token,
        secret,
        true,
        algorithm: "HS256"
      )
    }

    it "should have valid payload" do
      expect(
        decoded_payload.first["iss"]
      ).to eq(service_id)
    end
  end

  context 'options passed to the http client' do
    let(:client) { build :notifications_client, http_opts: options }
    let(:http_options) { client.speaker.http_opts }

    context 'with no additional options' do
      let(:options) { nil }

      it 'uses the defaults' do
        expect(
          http_options
        ).to eq(Notifications::Client::Speaker::DEFAULT_HTTP_OPTS)
      end
    end

    context 'with additional options' do
      let(:options) { { read_timeout: 80, ssl_timeout: 10 } }

      it 'merges the options into the defaults' do
        expect(
          http_options
        ).to eq(
          open_timeout: 60, read_timeout: 80, ssl_timeout: 10
        )
      end
    end
  end

  context 'configuration of the http request' do
    let(:response_double) { double(body: '{}') }

    it 'configures the http client' do
      expect(
        Net::HTTP
      ).to receive(:start).with(
        'api.notifications.service.gov.uk', 443, :ENV, { open_timeout: 60, read_timeout: 60, use_ssl: true }
      ).and_return(response_double)

      client.speaker.post('email', {})
    end
  end
end
