# GOV.UK notifications-ruby-client

Ruby client for the GOV.UK Notifications API
## Usage

Prior to usage an account must be created through the notify admin console. This will allow access to the API credentials you application.

You can then install the gem or require it in your application.

```
gem 'notifications-ruby-client'
```

The client requires the credentials when initialising: `service_id` (Your service id) and `secret_id` (API KEY).

```ruby
client = Notifications::Client.new(service_id, secret_id)
client = Notifications::Client.new(service_id, secret)
```

you can also override api endpoint

```ruby
client = Notifications::Client.new(service_id, secret, base_url)
client.base_url # => Notifications::Client::PRODUCTION_BASE_URL
```

### send sms or email

send sms or email providing recipient and template

```ruby
sms = client.send_sms(to: number, template: template_id)
email = client.send_email(to: number, template: template_id)
```

additionally you may provide personalisation fields

```ruby
sms = client.send_sms(
  to: number,
  template: template_id,
  personalisation: {
    name: "name",
    year: "2016"
  }
) # => Notifications::Client::ResponseNotification
```

returns a `Notifications::Client::ResponseNotification`, which has the notification's id

### get notifications

from an id

```ruby
notification = client.get_notification(sms.id)
notification.id         # => f163deaf-2d3f-4ec6-98fc-f23fa511518f
notification.to         # => 07515 987 456
notification.status     # => "delivered"
notification.created_at # => 2016-04-26T15:29:36.891512+00:00
```

or get them all

```ruby
notifications = client.get_notifications
notifications.links # => { last: "", next: "" }
notifications.total # => 162
notifications.page_size # => 50
notifications.collection # => [] (array of notification objects)
```

query parameters are also supported

```ruby
client.get_notifications(
  page: 2,
  limit_days: 3,
  page_size: 20,
  status: "delivered",
  template_type: "sms"
)
```

### exceptions

raised exceptions will contain error message and response status code

```ruby
client = Notifications::Client.new(base_url, invalid, invalid)
rescue Notifications::Client::RequestError => e
e.code # => 403
e.message # => Invalid credentials
```
