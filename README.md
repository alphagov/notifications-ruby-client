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
sms = client.send_sms(
  phone_number: number,
  template_id: template_id,
  personalisation: {
    name: "name",
    year: "2016",
  },
  reference: "your_reference_string",
  sms_sender_id: sms_sender_id
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
sms.content    # => Hash containing body => the message sent to the recipient, with placeholders replaced.
               #                    from_number => the sms sender number of your service found **Settings** page
sms.template   # => Hash containing id => id of the template
               #                    version => version of the template
               #                    uri => url of the template
sms.uri        # => URL of the notification
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
      "error": "RateLimitError",
      "message": "Exceeded rate limit for key type TEAM of 10 requests per 10 seconds"
      }]
      </pre>
      </td>
      </tr>
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
email = client.send_email(
  email_address: email_address,
  template_id: template_id,
  personalisation: {
    name: "name",
    year: "2016"
  },
  reference: "your_reference_string",
  email_reply_to_id: email_reply_to_id
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
     "error": "RateLimitError",
     "message": "Exceeded rate limit for key type TEAM of 10 requests per 10 seconds"
 }]
 </pre>
 </td>
 </tr>
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

Letter:

```ruby
letter = client.send_letter(
  template_id: template_id,
  personalisation: {
    address_line_1: 'Her Majesty The Queen',  # required
    address_line_2: 'Buckingham Palace', # required
    address_line_3: 'London',
    postcode: 'SW1 1AA',  # required

    ... # any other personalisation found in your template
  },
  reference: "your_reference_string"
) # => Notifications::Client::ResponseNotification
```

<details>
<summary>
Response
</summary>

If the request is successful, a `Notifications::Client:ResponseNotification` is returned

```ruby
letter => Notifications::Client::ResponseNotification

letter.id           # => uuid for the notification
letter.reference    # => Reference string you supplied in the request
letter.content      # => Hash containing body => the body of the letter sent to the recipient, with placeholders replaced
                    #                    subject => the main heading of the letter
letter.template     # => Hash containing id => id of the template
                    #                    version => version of the template
                    #                    uri => url of the template
letter.uri          # => URL of the notification
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
    "error": "RateLimitError",
    "message": "Exceeded rate limit for key type TEAM of 10 requests per 10 seconds"
}]
</pre>
</td>
</tr>
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
<tr>
<td>
<pre>400</pre>
</td>
<td>
<pre>
[{
    "error": "ValidationError",
    "message": "personalisation address_line_1 is a required property"
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

#### `sms_sender_id`
Optional. Specifies the identifier of the sms sender to set for the notification. The identifiers are found in your service Settings, when you 'Manage' your 'Text message sender'.

If you omit this argument your default sms sender will be set for the notification.

#### `personalisation`
If the template has placeholders you need to provide their values as a Hash, for example:

```ruby
  personalisation: {
    'first_name' => 'Amala',
    'reference_number' => '300241',
  }
```

You can omit this argument if the template does not contain placeholders and is for email or sms.

#### `personalisation` (for letters)

If you are sending a letter, you will need to provide the letter fields in the format `"address_line_#"`, for example:

```ruby
personalisation: {
    'address_line_1' => 'The Occupier',
    'address_line_2' => '123 High Street',
    'address_line_3' => 'London',
    'postcode' => 'SW14 6BH',
    'first_name' => 'Amala',
    'reference_number' => '300241',
}
```

The fields `address_line_1`, `address_line_2` and `postcode` are required.

#### `email_reply_to_id`

Optional. Specifies the identifier of the email reply-to address to set for the notification. The identifiers are found in your service Settings, when you 'Manage' your 'Email reply to addresses'. 

If you omit this argument your default email reply-to address will be set for the notification.

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
args = {
  'template_type' => 'sms',
  'status' => 'failed',
  'reference' => 'your reference string'
  'olderThanId' => 'e194efd1-c34d-49c9-9915-e4267e01e92e' # => Notifications::Client::Notification
}
notifications = client.get_notifications(args)
```
<details>
<summary>
Response
</summary>
If the request is successful a `Notifications::Client::NotificationsCollection` is returned.

```ruby
notifications.links # => Hash containing current => "/notifications?template_type=sms&status=delivered"
                    #                    next => "/notifications?other_than=last_id_in_list&template_type=sms&status=delivered"
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


## Get a template by ID
This will return the latest version of the template. Use [getTemplateVersion](#get-a-template-by-id-and-version) to retrieve a specific template version.

```ruby
template = client.get_template_by_id(template_id)
```

<details>
<summary>
Response
</summary>

```Ruby
template.id         # => uuid for the template
template.type       # => type of template one of email|sms|letter
template.created_at # => date and time the template was created
template.updated_at # => date and time the template was last updated, may be null if version 1
template.created_by # => email address of the person that created the template
template.version    # => version of the template
template.body       # => content of the template
template.subject    # => subject for email templates, will be empty for other template types
```

Otherwise the client will raise a `Notifications::Client::RequestError`.

<table>
<thead>
<tr>
<th>message</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<pre>
Status code: 404 {
"errors":
[{
    "error": "NoResultFound",
    "message": "No result found"
}]
}
</pre>
<pre>
Status code: 400 {
"errors":
[{
    "error": "ValidationError",
    "message": "id is not a valid UUID"
}]
}
</pre>
</tbody>
</table>
</details>

### Arguments

#### `templateId`
The template id is visible on the template page in the application.


## Get a template by ID and version
This will return the template for the given id and version.

```ruby
Template template = client.get_template_version(template_id template_id, version)
```

<details>
<summary>
Response
</summary>

```Ruby
template.id         # => uuid for the template
template.type       # => type of template one of email|sms|letter
template.created_at # => date and time the template was created
template.updated_at # => date and time the template was last updated, may be null if version 1
template.created_by # => email address of the person that created the template
template.version    # => version of the template
template.body       # => content of the template
template.subject    # => subject for email templates, will be empty for other template types
```

Otherwise the client will raise a `Notifications::Client::RequestError`.

<table>
<thead>
<tr>
<th>message</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<pre>
Status code: 404 {
"errors":
[{
    "error": "NoResultFound",
    "message": "No result found"
}]
}
</pre>
<pre>
Status code: 400 {
"errors":
[{
    "error": "ValidationError",
    "message": "id is not a valid UUID"
}]
}
</pre>
</tbody>
</table>
</details>

### Arguments

#### `templateId`
The template id is visible on the template page in the application.

#### `version`
A history of the template is kept. There is a link to `See previous versions` on the template page in the application.

## Get all templates
This will return the latest version of each template for your service.

```ruby
args = {
  'template_type' => 'sms'
}
templates = client.get_all_templates(args)
```

<details>
<summary>
Response
</summary>

```ruby
    TemplateCollection templates;
```
If the response is successful, a TemplateCollection is returned.

If no templates exist for a template type or there no templates for a service, the templates list will be empty.

Otherwise the client will raise a `Notifications::Client::RequestError`.


</details>

### Arguments

#### `templateType`
You can filter the templates by the following options:

* `email`
* `sms`
* `letter`
You can omit this argument to ignore this filter.


## Generate a preview template
This will return the contents of a template with the placeholders replaced with the given personalisation.
```ruby
templatePreview = client.generate_template_preview(template_id,
                                                  personalisation: {
                                                      name: "name",
                                                      year: "2016",                      
                                                    })
```

<details>
<summary>
Response
</summary>


```Ruby
template.id         # => uuid for the template
template.version    # => version of the template
template.body       # => content of the template
template.subject    # => subject for email templates, will be empty for other template types
```


Otherwise a `Notifications::Client::RequestError` is thrown.
<table>
<thead>
<tr>
<th>message</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<pre>
Status code: 404 {
"errors":
[{
    "error": "NoResultFound",
    "message": "No result found"
}]
}
</pre>
<pre>
Status code: 400 {
"errors":
[{
    "error": "ValidationError",
    "message": "id is not a valid UUID"
}]
}
</pre>
</tbody>
</table>

</details>

### Arguments

#### `templateId`
The template id is visible on the template page in the application.

#### `personalisation`
If a template has placeholders, you need to provide their values. `personalisation` can be an empty or null in which case no placeholders are provided for the notification.
