# Contributing

Pull requests are welcome.

## Setting Up

### Docker container

This app uses dependencies that are difficult to install locally. In order to make local development easy, we run app commands through a Docker container. Run the following to set this up:

```shell
make bootstrap-with-docker
```

Because the container caches things like packages, you will need to run this again if you change the package versions.

## Tests

There are unit and integration tests that can be run to test functionality of the client.

## Unit Tests

To run the unit tests:

```
make test-with-docker
```

## Integration Tests

Before running the integration tests, please ensure that the environment variables are set up.

```sh
export NOTIFY_API_URL="https://example.notify-api.url"
export API_KEY="example_API_test_key"
export FUNCTIONAL_TEST_NUMBER="valid mobile number"
export FUNCTIONAL_TEST_EMAIL="valid email address"
export EMAIL_TEMPLATE_ID="valid email_template_id"
export SMS_TEMPLATE_ID="valid sms_template_id"
export LETTER_TEMPLATE_ID="valid letter_template_id"
export EMAIL_REPLY_TO_ID="valid email reply to id"
export SMS_SENDER_ID="valid sms_sender_id - to test sending to a receiving number, so needs to be a valid number"
export API_SENDING_KEY="API_team_key for sending a SMS to a receiving number"
export INBOUND_SMS_QUERY_KEY="API_test_key to get received text messages"
```

To run the integration tests:

```
make integration-test-with-docker
```

## Releasing (for notify developers only)

To release manually, run `make publish-to-rubygems`. You will need to set the environment variable `GEM_HOST_API_KEY`, which can be found in the credentials repo under `credentials/rubygems/api_key`.
