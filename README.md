# GOV.UK Notify Ruby client

API client for GOV.UK Notify written in Ruby.

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
client = Notifications::Client.new(api_key)
```

Generate an API key by logging in to GOV.UK Notify [GOV.UK Notify](https://www.notifications.service.gov.uk) and going to the **API integration** page.

### Send a message

Text message:

```ruby
require 'notifications/client/response_notification'
sms = client.send_sms(phone_number: number,
                      template_id: template_id,
                      personalisation: Hash[name: "name",
                                        year: "2016",                      
                                      ],
                      reference: "your_reference_string"
                      ) # => Notifications::Client::ResponseNotification
```

<details>
<summary>
Response
</summary>

If the request is successful, a `Notifications::Client:ResponseNotification` is returned

```ruby
sms => Notifications::Client::ResponseNotification

sms.id         # => uuid for the notification
sms.reference  # => Reference string you supplied in the request
sms.type       # => sms
sms.status     # => status of the message "created|pending|sent|delivered|permanent-failure|temporary-failure"
content        # => Hash containing body => the message sent to the recipient, with placeholders replaced.
               #                    from_number => the sms sender number of your service found **Settings** page
template       # => Hash containing id => id of the template
               #                    version => version of the template
               #                    uri => url of the template    
uri            # => URL of the notification
```

Otherwise the client will raise a `Notifications::Client::RequestError`:
<table>
 <thead>
   <tr>
    <th>error.code</th>
    <th>error.message</th>
   </tr>
 </thead>
 <tbody>
   <tr>
    <td>
      <pre>429</pre>
    </td>
    <td>
      <pre>
      [{
          "error": "TooManyRequestsError",
          "message": "Exceeded send limits (50) for today"
      }]
      </pre>
    </td>
  </tr>
  <tr>
    <td>
      <pre>400</pre>
    </td>
    <td>
      <pre>
      [{
          "error": "BadRequestError",
          "message": "Can"t send to this recipient using a team-only API key"
      ]}
      </pre>
    </td>
  </tr>
  <tr>
    <td>
      <pre>400</pre>
    </td>
    <td>
      <pre>
      [{
          "error": "BadRequestError",
          "message": "Can"t send to this recipient when service is in trial mode
                      - see https://www.notifications.service.gov.uk/trial-mode"
      }]
      </pre>
    </td>
  </tr>
</tbody>
</table>
</details>                  


Email:

```ruby
require 'notifications/client/response_notification'
email = client.send_email(email_address: email_address,
                          template: template_id,
                          personalisation: Hash[name: "name",
                                            year: "2016"
                                          ],
                          reference: "your_reference_string"
                        ) # => Notifications::Client::ResponseNotification
```

<details>
<summary>
Response
</summary>

If the request is successful, a `Notifications::Client:ResponseNotification` is returned

```ruby
email => Notifications::Client::ResponseNotification

email.id         # => uuid for the notification
email.reference  # => Reference string you supplied in the request
email.type       # => sms
email.status     # => status of the message "created|pending|sent|delivered|permanent-failure|temporary-failure"
email.content    # => Hash containing body => the message sent to the recipient, with placeholders replaced.
                 #                    subject => subject of the message sent to the recipient, with placeholders replaced.
                 #                    from_email => the from email of your service found **Settings** page
email.template   # => Hash containing id => id of the template
                 #                    version => version of the template
                 #                    uri => url of the template    
email.uri        # => URL of the notification
```

Otherwise the client will raise a `Notifications::Client::RequestError`:
<table>
 <thead>
   <tr>
    <th>error.code</th>
    <th>error.message</th>
   </tr>
 </thead>
 <tbody>
   <tr>
    <td>
      <pre>429</pre>
    </td>
    <td>
      <pre>
      [{
          "error": "TooManyRequestsError",
          "message": "Exceeded send limits (50) for today"
      }]
      </pre>
    </td>
  </tr>
  <tr>
    <td>
      <pre>400</pre>
    </td>
    <td>
      <pre>
      [{
          "error": "BadRequestError",
          "message": "Can"t send to this recipient using a team-only API key"
      ]}
      </pre>
    </td>
  </tr>
  <tr>
    <td>
      <pre>400</pre>
    </td>
    <td>
      <pre>
      [{
          "error": "BadRequestError",
          "message": "Can"t send to this recipient when service is in trial mode
                      - see https://www.notifications.service.gov.uk/trial-mode"
      }]
      </pre>
    </td>
  </tr>
</tbody>
</table>
</details>

### Arguments
#### `phone_number`
The phone number of the recipient, only required when using `client.send_sms`.

#### `email_address`
The email address of the recipient, only required when using `client.send_email`.

#### `template_id`
Find by clicking **API info** for the template you want to send.

#### `reference`
An optional identifier you generate. The `reference` can be used as a unique reference for the notification. Because Notify does not require this reference to be unique you could also use this reference to identify a batch or group of notifications.

You can omit this argument if you do not require a reference for the notification.

#### `personalisation`
If the template has placeholders you need to provide their values as a Hash, for example:

```ruby
  personalisation=Hash[
                        'first_name': 'Amala',
                        'reference_number': '300241',
                      ]
```

You can omit this argument if the template does not contain placeholders.

### Get the status of one message

```ruby
notification = client.get_notification(id) # => Notifications::Client::Notification
```

<details>
<summary>
Response
</summary>
If successful a `Notifications::Client::Notification is returned.

```ruby
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
Otherwise a `Notification::Client::RequestError` is raised

<table>
<thead>
<tr>
<th>`error.code`</th>
<th>`error.message`</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<pre>404</pre>
</td>
<td>
<pre>
[{
    "error": "NoResultFound",
    "message": "No result found"
}]
</pre>
</td>
</tr>
<tr>
<td>
<pre>400</pre>
</td>
<td>
<pre>
[{
    "error": "ValidationError",
    "message": "id is not a valid UUID"
}]
</pre>
</td>
</tr>
</tbody>
</table>
</details>

</details>
### Get the status of all messages

```ruby
# See section below for a description of the arguments.
args = Hash[
            'template_type', 'sms',
            'status', 'failed',
            'reference', 'your reference string'
            'olderThanId', 'e194efd1-c34d-49c9-9915-e4267e01e92e' # => Notifications::Client::Notification
            ]
notifications = client.get_notifications(args)
```
<details>
<summary>
Response
</summary>
If the request is successful a `Notifications::Client::NotificationsCollection` is returned.

```ruby
notifications.links # => Hash containing current=>"/notifications?template_type=sms&status=delivered"
next=>"/notifications?other_than=last_id_in_list&template_type=sms&status=delivered"}
notifications.collection # => [] (array of notification objects)
```
Otherwise the client will raise a `Notifications::Client::RequestError`:
<table>
<thead>
<tr>
<th>error.status_code</th>
<th>error.message</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<pre>400</pre>
</td>
<td>
<pre>
[{
	'error': 'ValidationError',
    'message': 'bad status is not one of [created, sending, delivered, pending, failed, technical-failure, temporary-failure, permanent-failure]'
}]
</pre>
</td>
</tr>
<tr>
<td>
<pre>400</pre>
</td>
<td>
<pre>
[{
    "error": "ValidationError",
    "message": "Apple is not one of [sms, email, letter]"
}]
</pre>
</td>
</tr>
</tbody>
</table>
</details>

### Arguments
Omit the argument Hash if you do not want to filter the results.
#### `template_type`

You can filter by:

* `email`
* `sms`
* `letter`

You can omit this argument to ignore the filter.

#### `status`

You can filter by:

* `sending` - the message is queued to be sent by the provider.
* `delivered` - the message was successfully delivered.
* `failed` - this will return all failure statuses `permanent-failure`, `temporary-failure` and `technical-failure`.
* `permanent-failure` - the provider was unable to deliver message, email or phone number does not exist; remove this recipient from your list.
* `temporary-failure` - the provider was unable to deliver message, email box was full or the phone was turned off; you can try to send the message again.
* `technical-failure` - Notify had a technical failure; you can try to send the message again.

You can omit this argument to ignore the filter.

### `reference`

This is the `reference` you gave at the time of sending the notification. The `reference` can be a unique identifier for the notification or an identifier for a batch of notifications.

You can omit this argument to ignore the filter.


#### `olderThanId`
You can get the notifications older than a given `Notification.id`.
You can omit this argument to ignore this filter.
