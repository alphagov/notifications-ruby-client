# GOV.UK Notify Ruby client

API client for GOV.UK Notify written in Ruby.

[![Build Status](https://travis-ci.org/alphagov/notifications-ruby-client.svg?branch=master)](https://travis-ci.org/alphagov/notifications-ruby-client)
[![Gem Version](https://badge.fury.io/rb/notifications-ruby-client.svg)](https://badge.fury.io/rb/notifications-ruby-client)

## Installation

Prior to usage an account must be created through the Notify admin console. This will allow access to the API credentials you application.

You can then install the gem or require it in your application.

```
gem install 'notifications-ruby-client'
```

## Getting started

```ruby
require 'notifications/client'
client = Notifications::Client.new(service_id, secret_id)
```

you can also override api endpoint

```ruby
client = Notifications::Client.new(service_id, secret_id, base_url)
client.base_url # => Notifications::Client::PRODUCTION_BASE_URL
```

Generate an API key by logging in to GOV.UK Notify [GOV.UK Notify](https://www.notifications.service.gov.uk) and going to the API integration page.

You will find your service ID on the API integration page.

### Send a message

Text message:

```ruby
sms = client.send_sms(to: number, 
                      template: template_id,
                      personalisation: {
                      name: "name",
                      year: "2016"
  }
)

```

Email:
```ruby
email = client.send_email(to: number, template: template_id)

sms = client.send_sms(
  to: number,
  template: template_id,
  personalisation: {
    name: "name",
    year: "2016"
  }
) # => Notifications::Client::ResponseNotification
```

Find `template_id` by clicking **API info** for the template you want to send.

If a template has placeholders, you need to provide their values in `personalisation`. Otherwise do not pass in `personalisation`

If successful the response is a `Notifications::Client::ResponseNotification`, which has the notification id.
Otherwise a Notifications::Client::RequestError is returned.


### Get the status of one message

```ruby
notification = client.get_notification(id) # => Notifications::Client::Notification
notification.id         # => uuid for the notification
notification.to         # => recipient email address or mobile number
notification.status     # => status of the message "created|pending|sent|delivered|permanent-failure|temporary-failure" 
notification.created_at # => Date time the message was created
notification.api_key    # => uuid for the api key (not the actual api key)
notification.billable_units # => units billable or nil for email
notification.subject    # => Subject of email or nil for sms
notification.body       # => Body of message
notification.job        # => job id if created by a csv or nil if message sent via api
notification.notification_type # => sms | email
notification.service    # => uuid for service
notification.sent_at    # => Date time the message is sent to the provider or nil if status = "created"
notification.sent_by    # => Name of the provider that sent the message or nil if status = "created"
notification.template   # => Hash containing template id, name, version, template type sms|email
notification.template_version # Template version number
notification.reference  # => reference of the email or nil for sms
notification.updated_at # => Date time that the notification was last updated
```

### Get the status of all messages

```ruby
notifications = client.get_notifications
notifications.links # => {"last"=>"/notifications?page=4", "next"=>"/notifications?page=2"}
notifications.total # => 202
notifications.page_size # => 50
notifications.collection # => [] (array of notification objects)

```

Query parameters are also supported

```ruby
client.get_notifications(
  page: 2,
  limit_days: 3,
  page_size: 20,
  status: "delivered",
  template_type: "sms"
)
```

### Exceptions

Raised exceptions will contain error message and response status code

```ruby
client = Notifications::Client.new(base_url, invalid, invalid)
rescue Notifications::Client::RequestError => e
e.code # => 403
e.message # => Invalid credentials
```
<table>
  <thead>
    <tr>
      <td> Code </td>
      <td> Message </td>
     </tr>
  </thead>
  <tbdoy>
  <tr>
    <td> 403 </td>
    <td> {"token"=>["Invalid token: signature"]} </td>
  </tr>
  <tr>
    <td> 403 </td>
    <td> {"token"=>["Invalid token: expired"]} </td>
  </tr>
  <tr>
    <td> 429 </td>
    <td> Exceeded send limits (50) for today </td>
  </tr>
  <tr>
    <td> 400 </td>
    <td> Can’t send to this recipient using a team-only API key </td>
  </tr>
  <tr>
    <td> 400 </td>
    <td> Can’t send to this recipient when service is in trial 
          mode - see https://www.notifications.service.gov.uk/trial-mode
    </td>
  </tr>
  </tbody>
</table>
