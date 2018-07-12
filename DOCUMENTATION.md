# Ruby client documentation

This documentation is for developers interested in using the GOV.UK Notify Ruby client to send emails, text messages or letters.

# Set up the client

## Install the client

Run the following code in the command line:

```
gem install 'notifications-ruby-client'
```

Refer to the [client changelog](https://github.com/alphagov/notifications-ruby-client/blob/master/CHANGELOG.md) for the version number and the latest updates.

## Create a new instance of the client

Add this code to your application:

```ruby
require 'notifications/client'
client: Notifications::Client.new(api_key)
```

To get an API key, [sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/) and go to the __API integration__ page. You can find more information in the [API keys](/#api-keys) section of the documentation.

# Send a message

You can use GOV.UK Notify to send text messages, emails and letters.

## Send a text message

### Method

```ruby
sms: client.send_sms(
  phone_number: "+447900900123",
  template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
)
```

### Arguments

#### phone_number (required)

The phone number of the recipient of the text message. This number can be a UK or international number.

```ruby
phone_number:"+447900900123",
```

#### template_id (required)

You can find this by signing into [GOV.UK Notify](https://www.notifications.service.gov.uk/) and going to the __Templates__ page.

```ruby
template_id:"f33517ff-2a88-4f6e-b855-c550268ce08a",
```

#### personalisation (optional)

If a template has placeholder fields for personalised information such as name or reference number, you must provide their values in a hash. For example:

```ruby
personalisation: {
  name: "John Smith",
  ID: "300241",                      
}
```

You can leave out this argument if a template does not have any placeholder fields for personalised information.

#### reference (optional)

A unique identifier. This reference identifies a single unique notification or a batch of notifications.

```ruby
reference: "your_reference_string",
```

You can leave out this argument if you do not have a `reference`.

#### sms_sender_id (optional)

A unique identifier of the sender of the text message notification. To find this information, go to the __Text Message sender__ settings screen:

1. Sign in to your GOV.UK Notify account.
1. Go to __Settings__.
1. If you need to change to another service, select __Switch service__ in the top right corner of the screen and select the correct one.
1. Go to the __Text Messages__ section and select __Manage__ on the __Text Message sender__ row.

In this screen, you can then either:

  - copy the sender ID that you want to use and paste it into the method
  - select __Change__ to change the default sender that the service will use, and select __Save__

```ruby
sms_sender_id: "8e222534-7f05-4972-86e3-17c5d9f894e2",
```

You can leave out this argument if you do not have have an `sms_sender_id`.

### Response

If the request to the client is successful, the client will return a `Notifications::Client:ResponseNotification`:

```ruby
 @content={'notification content'},
 @id="6e5c4f6f-26b0-44c8-8aa9-fa71616c2542",
 @reference="your_reference_string",
 @template=
  {"id"=>"f33517ff-2a88-4f6e-b855-c550268ce08a",
   "uri"=> "http://localhost:6011/services/bb86bffc-3065-4a91-8c3c-e077ad9d9a2b/templates/8e222534-7f05-4972-86e3-17c5d9f894e2",
   "version"=>4},
 @uri=>"http://localhost:6011/v2/notifications/6e5c4f6f-26b0-44c8-8aa9-fa71616c2542">
```

If you are using the [test API key](/#test), all your messages will come back as delivered.

All messages sent using the [team and whitelist](#team-and-whitelist) or [live](#live) keys will appear on your dashboard.

### Error codes

If the request is not successful, the client will return a `Notifications::Client::RequestError` containing the relevant error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Can't send to this recipient using a team-only API key"`<br>`]}`|Use the correct type of [API key](/#api-keys)|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Can't send to this recipient when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode"`<br>`}]`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode)|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/#api-keys) for more information|
|`429`|`[{`<br>`"error": "RateLimitError",`<br>`"message": "Exceeded rate limit for key type TEAM/TEST/LIVE of 3000 requests per 60 seconds"`<br>`}]`|Refer to [API rate limits](/#api-rate-limits) for more information|
|`429`|`[{`<br>`"error": "TooManyRequestsError",`<br>`"message": "Exceeded send limits (LIMIT NUMBER) for today"`<br>`}]`|Refer to [service limits](/#service-limits) for the limit number|
|`500`|`[{`<br>`"error": "Exception",`<br>`"message": "Internal server error"`<br>`}]`|Notify was unable to process the request, resend your notification|

## Send an email

### Method

```ruby
email: client.send_email(
  email_address: "sender@something.com",
  template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
)
```

### Arguments

#### email_address (required)

The email address of the recipient.

```ruby
email_address: "sender@something.com",
```

#### template_id (required)

You can find this by signing into GOV.UK Notify and going to the __Templates__ page.

```ruby
template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
```

#### personalisation (optional)

If a template has placeholder fields for personalised information such as name or reference number, you must provide their values in a hash. For example:

```ruby
personalisation: {
  name: "John Smith",
  year: "2016"                      
}
```

You can leave out this argument if a template does not have any placeholder fields for personalised information.

#### reference (optional)

A unique identifier. This reference identifies a single unique notification or a batch of notifications.

```ruby
reference: "your_reference_string";
```

You can leave out this argument if you do not have a `reference`.

#### email_reply_to_id (optional)

This is an email reply-to address specified by you to receive replies from your users. Your service cannot go live until you set up at least one of these email addresses. To set up:

1. Sign into your GOV.UK Notify account.
1. Go to __Settings__.
1. If you need to change to another service, select __Switch service__ in the top right corner of the screen and select the correct one.
1. Go to the Email section and select __Manage__ on the __Email reply to addresses__ row.
1. Select __Change__ to specify the email address to receive replies, and select __Save__.

```ruby
email_reply_to_id: '8e222534-7f05-4972-86e3-17c5d9f894e2'
```

You can leave out this argument if you do not have have an `email_reply_to_id`.

### Response

If the request to the client is successful, the client will return a `Notifications::Client:ResponseNotification`:

```ruby
 @content={"notification content"},
 @id="e1654fd8-a263-417a-935d-9ca78e7b8904",
 @reference="your_reference_string",
 @template=
  {"id"=>"f33517ff-2a88-4f6e-b855-c550268ce08a",
   "uri"=> "http://localhost:6011/services/bb86bffc-3065-4a91-8c3c-e077ad9d9a2b/templates/f33517ff-2a88-4f6e-b855-c550268ce08a",
   "version"=>3},
 @uri="http://localhost:6011/v2/notifications/e1654fd8-a263-417a-935d-9ca78e7b8904">
```

### Error codes

If the request is not successful, the client will return a `Notifications::Client::RequestError` containing the relevant error code:

|error.code|error.message|How to fix|
|:--- |:---|:---|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Can't send to this recipient using a team-only API key"`<br>`]}`|Use the correct type of [API key](/#api-keys)|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Can't send to this recipient when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode"`<br>`}]`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode)|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/#api-keys) for more information|
|`429`|`[{`<br>`"error": "RateLimitError",`<br>`"message": "Exceeded rate limit for key type TEAM/TEST/LIVE of 3000 requests per 60 seconds"`<br>`}]`|Refer to [API rate limits](/#api-rate-limits) for more information|
|`429`|`[{`<br>`"error": "TooManyRequestsError",`<br>`"message": "Exceeded send limits (LIMIT NUMBER) for today"`<br>`}]`|Refer to [service limits](/#service-limits) for the limit number|
|`500`|`[{`<br>`"error": "Exception",`<br>`"message": "Internal server error"`<br>`}]`|Notify was unable to process the request, resend your notification|

## Send a letter

When your service first signs up to GOV.UK Notify, you’ll start in trial mode. You can only send letters in live mode.

### Method

```ruby
letter: client.send_letter(
  template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
  personalisation: {
    address_line_1: 'The Occupier',  # required string
    address_line_2: '123 High Street', # required string
    postcode: 'SW14 6BH',  # required string
  },
)
```

### Arguments

#### template_id (required)

You can find this by signing into GOV.UK Notify and going to the __Templates__ page.

```ruby
template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
```

#### personalisation (required)

The personalisation argument always contains the following parameters for the letter recipient's address:

- `address_line_1`
- `address_line_2`
- `postcode`

Any other placeholder fields included in the letter template also count as required parameters. You must provide their values in a hash. For example:


```ruby
personalisation: {
  address_line_1: 'The Occupier',  # mandatory address field
  address_line_2: '123 High Street', # mandatory address field
  postcode: 'SW14 6BH',  # mandatory address field
  name: 'John Smith', # field from template
  application_date: '2018-01-01' # field from template
},
```

#### personalisation (optional)

The following parameters in the letter recipient's address are optional:

```ruby
personalisation: {
  address_line_3: 'Richmond',  # mandatory address field
  address_line_4: 'London', # mandatory address field
  address_line_5: 'Middlesex', # mandatory address field
  address_line_6: 'UK', # mandatory address field
},
```

#### reference (optional)

A unique identifier. This reference identifies a single unique notification or a batch of notifications. If you do not have a reference, you must pass in an empty string or `null`.

```ruby
reference: 'your_reference_string';
```

### Response

If the request to the client is successful, the client will return a `Notifications::Client:ResponseNotification`:

```ruby
@content={"notification content"},
@id="8a6f5cb9-98d1-436d-bdb0-15cc2edc8e65",
@reference=nil,
@template=
 {"id"=>"f33517ff-2a88-4f6e-b855-c550268ce08a",
  "uri"=>"https://api.notify.works/services/d33f763f-d8b6-4591-b272-ec6127572e5a/templates/2dd69cce-c0d2-470f-a6c1-8900a5368e04",
  "version"=>3},
@uri="https://api.notify.works/v2/notifications/8a6f5cb9-98d1-436d-bdb0-15cc2edc8e65">
```

### Error codes

If the request is not successful, the client will return a `Notifications::Client::RequestError` containing the relevant error code:

|error.code|error.message|How to fix|
|:--- |:---|:---|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Cannot send letters with a team api key"`<br>`]}`|Use the correct type of [API key](/#api-keys)|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Cannot send letters when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode"`<br>`}]`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode)|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "personalisation address_line_1 is a required property"`<br>`}]`|Ensure that your template has a field for the first line of the address, refer to [personalisation](/#send-a-letter-arguments-personalisation-required) for more information|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/#api-keys) for more information|
|`429`|`[{`<br>`"error": "RateLimitError",`<br>`"message": "Exceeded rate limit for key type TEAM/TEST/LIVE of 3000 requests per 60 seconds"`<br>`}]`|Refer to [API rate limits](/#api-rate-limits) for more information|
|`429`|`[{`<br>`"error": "TooManyRequestsError",`<br>`"message": "Exceeded send limits (LIMIT NUMBER) for today"`<br>`}]`|Refer to [service limits](/#service-limits) for the limit number|
|`500`|`[{`<br>`"error": "Exception",`<br>`"message": "Internal server error"`<br>`}]`|Notify was unable to process the request, resend your notification|

# Get message status

Message status depends on the type of message that you have sent.

You can only get the status of messages that are 7 days old or less.

## Status - text and email

### Created

The message is queued to be sent to the provider. The notification usually remains in this state for a few seconds.

### Sending

The message is queued to be sent by the provider to the recipient, and GOV.UK Notify are waiting for delivery information.

### Pending (text message only)

GOV.UK Notify received a callback from the provider but the device has not yet responded. Another callback from the provider will determine the final status of the notification.

### Delivered

The message was successfully delivered.

### Sent (text message only)

The text message was delivered internationally. GOV.UK Notify may not receive additional status updates depending on the recipient's country and telecoms provider.

### Failed

This covers all failure statuses:

- `permanent-failure` - "The provider was unable to deliver message, email or phone number does not exist; remove this recipient from your list"
- `temporary-failure` - "The provider was unable to deliver message, email inbox was full or phone was turned off; you can try to send the message again"
- `technical-failure` - "Notify had a technical failure; you can try to send the message again"

## Status - letter

### Failed

The only failure status that applies to letters is `technical-failure`. Notify had an unexpected error while sending to our printing provider.

### Accepted

GOV.UK Notify is printing and posting the letter.

### Received

The provider has received the letter to deliver.


## Get the status of one message

You can only get the status of messages that are 7 days old or less.

### Method

```ruby
notification: client.get_notification(id)
```

### Arguments

#### id (required)

The ID of the notification.

### Response

If the request to the client is successful, the client will return a `Notifications::Client::Notification`:

```ruby
@body="Body",
 @completed_at="2018-06-26T15:42:29.972008Z",
 @created_at="2018-06-26T15:42:11.277321Z",
 @email_address=nil,
 @id="2fbcf138-19ed-4f9c-976d-3f28c86eda11",
 @line_1="one",
 @line_2="two",
 @line_3=nil,
 @line_4=nil,
 @line_5=nil,
 @line_6=nil,
 @phone_number=nil,
 @postcode="post c0de",
 @reference=nil,
 @sent_at=nil,
 @status="received",
 @subject="Heading of the letter",
 @template={"id"=>"2c6db85e-6caf-4e21-af95-2873bae251c5", "uri"=>"https://api.notify.works/v2/template/2c6db85e-6caf-4e21-af95-2873bae251c5/version/4", "version"=>4},
 @type="letter">
```

### Error codes

If the request is not successful, the client will return a `Notification::Client::RequestError` containing the relevant error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "id is not a valid UUID"`<br>`}]`|Check the notification ID|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/#api-keys) for more information|
|`404`|`[{`<br>`"error": "NoResultFound",`<br>`"message": "No result found"`<br>`}]`|Check the notification ID. This error will occur if the notification is more than 7 days old.|

## Get the status of multiple messages

This API call will return one page of up to 250 messages and statuses. You can get either the most recent messages, or get older messages by specifying a particular notification ID in the [`older_than`](/#older_than_optional) argument.

You can only get the status of messages that are 7 days old or less.

### Method

```ruby
args = {
  template_type: 'sms',
  status: 'failed',
  reference: 'your_reference_string'
  older_than: 'e194efd1-c34d-49c9-9915-e4267e01e92e' # => Notifications::Client::Notification
}
notifications = client.get_notifications(args)
```

You can leave out the `older_than` argument to get the 250 most recent messages.

To get older messages, pass the ID of an older notification into the `older_than` argument. This will return the next 250 oldest messages from the specified notification ID.

### Arguments

You can leave out these arguments to ignore these filters.

#### status (optional)

| status | description | text | email | letter |
|:--- |:--- |:--- |:--- |:--- |
|`created` |The message is queued to be sent to the provider|Yes|Yes||
|`sending` |The message is queued to be sent by the provider to the recipient|Yes|Yes||
|`delivered`|The message was successfully delivered|Yes|Yes||
|`pending`|GOV.UK Notify received a callback from the provider but the device has not yet responded|Yes|||
|`sent`|The text message was delivered internationally|Yes|Yes||
|`failed`|This will return all failure statuses:<br>- `permanent-failure`<br>- `temporary-failure`<br>- `technical-failure`|Yes|Yes||
|`permanent-failure`|The provider was unable to deliver message, email or phone number does not exist; remove this recipient from your list|Yes|Yes||
|`temporary-failure`|The provider was unable to deliver message, email inbox was full or phone was turned off; you can try to send the message again|Yes|Yes||
|`technical-failure`|Email / Text: Notify had a technical failure; you can try to send the message again. <br><br>Letter: Notify had an unexpected error while sending to our printing provider. <br><br>You can leave out this argument to ignore this filter.|Yes|Yes||
|`accepted`|Notify is printing and posting the letter|||Yes|
|`received`|The provider has received the letter to deliver|||Yes|

#### notificationType (optional)

You can filter by:

* `email`
* `sms`
* `letter`

#### reference (optional)

A unique identifier. This reference identifies a single unique notification or a batch of notifications.

```ruby
reference: 'your_reference_string';
```

#### older_than (optional)

Input the ID of a notification into this argument. If you use this argument, the client returns the next 250 received notifications older than the given ID.

```ruby
older_than: 'e194efd1-c34d-49c9-9915-e4267e01e92e'
```

If you leave out this argument, the client returns the most recent 250 notifications.

The client will only return notifications that are 7 days old or less. If the notification specified in this argument is older than 7 days, the client will return an empty `collection` response.

### Response

If the request to the client is successful, the client will return a `Notifications::Client::NotificationsCollection`.

You must then run either `notifications.links` or `notifications.collection` on the `Notifications::Client::NotificationsCollection` object:

- `notifications.links` returns a hash linking to the requested notifications (limited to 250)
- `notifications.collection` returns an array of the required notifications

A notification will take this format:

```ruby
<Notifications::Client::Notification:0x007fd00c8707d8
    @body: "notification content",
    @completed_at: nil,
    @created_at: "2018-04-12T11:00:59.200506Z",
    @email_address: "sender@something.com",
    @id: "9f2b4db3-fa0f-4b45-9314-8cb4019db209",
    @line_1: nil,
    @line_2: nil,
    @line_3: nil,
    @line_4: nil,
    @line_5: nil,
    @line_6: nil,
    @phone_number: nil,
    @postcode: nil,
    @reference: nil,
    @sent_at: "2018-04-12T11:01:01.452472Z",
    @status: "sending",
    @subject: "The day – a reminder",
    @template:
     {"id": "44d258d7-9cc9-40f8-b208-5fb67e751664", "uri": "http://localhost:6011/v2/template/44d258d7-9cc9-40f8-b208-5fb67e751664/version/1", "version": 1},
    @type: "email">
```

If the notification specified in the `older_than` argument is older than 7 days, the client will return an empty `collection` response:

```ruby
 @collection=[],
 @links={"current"=>"https://api.notify.works/v2/notifications?older_than=f927a003-7f5d-400d-a518-1bd0b205e4bf"}>
```

### Error codes

If the request is not successful, the client will return a `Notifications::Client::RequestError` containing the relevant error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "bad status is not one of [created, sending, sent, delivered, pending, failed, technical-failure, temporary-failure, permanent-failure, accepted, received]"`<br>`}]`|Contact the Notify team|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "Applet is not one of [sms, email, letter]"`<br>`}]`|Contact the Notify team|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/#api-keys) for more information|

# Get a template

## Get a template by ID

### Method

This will return the latest version of the template.

```ruby
Template: client.get_template_by_id(id)
```

### Arguments

#### templateId (required)

The ID of the template. You can find this by signing into GOV.UK Notify and going to the __Templates__ page.

```
id:'f33517ff-2a88-4f6e-b855-c550268ce08a';
```

### Response

If the request to the client is successful, the client will return a `template`:

_NEED EXAMPLE_

### Error codes

If the request is not successful, the client will return a `Notifications::Client::RequestError` containing the relevant error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "id is not a valid UUID"`<br>`}]`|Check the notification ID|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/#api-keys) for more information|
|`404`|`[{`<br>`"error": "NoResultFound",`<br>`"message": "No Result Found"`<br>`}]`|Check your [template ID](/#arguments-template-id-required)|

## Get a template by ID and version

### Method

This will return the latest version of the template.

```ruby
template: client.get_template_version(id, version)
```

### Arguments

#### id (required)

The ID of the template. You can find this by signing into GOV.UK Notify and going to the __Templates__ page.

```ruby
id: 'f33517ff-2a88-4f6e-b855-c550268ce08a';
```

#### version (required)

The version number of the template.

### Response

If the request to the client is successful, the client will return a `Template`:

_NEED EXAMPLE_

### Error codes

If the request is not successful, the client will return a `Notifications::Client::RequestError` containing the relevant error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`404`|`[{`<br>`"error": "NoResultFound",`<br>`"message": "No result found"`<br>`}]`|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "id is not a valid UUID"`<br>`}]`|Check the notification ID|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/#api-keys) for more information|
|`404`|`[{`<br>`"error": "NoResultFound",`<br>`"message": "No Result Found"`<br>`}]`|Check your [template ID](/#get-a-template-by-id-and-version-arguments-template-id-required) and [version](/#version)|

## Get all templates

### Method

This will return the latest version of all templates inside a collection named `templates`.

```ruby
args: {
  'type' => 'sms'
}
templates: client.get_all_templates(args)
```

### Arguments

#### type (optional)

If you do not use `type`, the client returns all templates. Otherwise you can filter by:

- `email`
- `sms`
- `letter`

### Response

If the request to the client is successful, the client will return a `Notifications::Client::TemplateCollection`:

```ruby
TemplateCollection "TemplateCollectionName";
```

You must then run `TemplateCollectionName.collection` to return an array of the required templates.

A template will take this format:

_NEED EXAMPLE_

If no templates exist for a template type or there no templates for a service, the templates list will be empty.

_NEED EXAMPLE_

### Error codes

If the request is not successful, the client will return a `Notifications::Client::RequestError` containing the relevant error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "Template type is not one of [sms, email, letter]"`<br>`}]`|Contact the Notify team|

## Generate a preview template

### Method

This will generate a preview version of a template.

```ruby
template_preview: client.generate_template_preview(id, personalisation{})
```

The parameters in the personalisation argument must match the placeholder fields in the actual template. The API notification client will ignore any extra fields in the method.

### Arguments

#### id (required)

The ID of the template. You can find this by signing into GOV.UK Notify and going to the __Templates__ page.

```ruby
id: 'f33517ff-2a88-4f6e-b855-c550268ce08a';
```

#### personalisation (required)

If a template has placeholder fields for personalised information such as name or application date, you must provide their values in a hash. For example:

```ruby
personalisation: {
  name: "John Smith",
  ID: "300241",                      
}
```

You can leave out this argument if a template does not have any placeholder fields for personalised information.

### Response

If the request to the client is successful, the client will return a `TemplatePreview`:

_NEED EXAMPLE_

### Error codes

If the request is not successful, the client will return a `Notifications::Client::RequestError` containing the relevant error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Missing personalisation: [PERSONALISATION FIELD]"`<br>`}]`|Check that the personalisation arguments in the method match the placeholder fields in the template|
|`400`|`[{`<br>`"error": "NoResultFound",`<br>`"message": "No result found"`<br>`}]`|Check the [template ID](/#generate-a-preview-template-required-arguments-template-id)|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/#api-keys) for more information|

# Get received text messages

This API call will return one page of up to 250 received text messages. You can get either the most recent messages, or get older messages by specifying a particular notification ID in the `older_than` argument.

You can only get the status of messages that are 7 days old or less.

### Method

```ruby
args: {
  'older_than' => 'e194efd1-c34d-49c9-9915-e4267e01e92e' # => Notifications::Client::ReceivedText
}
received_texts: client.get_received_texts(args)
```

To get older messages, pass the ID of an older notification into the `older_than` argument. This will return the next oldest messages from the specified notification ID.

If you leave out the `older_than` argument, the client returns the most recent 250 notifications.

### Arguments

#### older_than (optional)

Input the ID of a received text message into this argument. If you use this argument, the client returns the next 250 received text messages older than the given ID.

```ruby
older_than: '8e222534-7f05-4972-86e3-17c5d9f894e2'
```

If you leave out the `older_than` argument, the client returns the most recent 250 notifications.

The client will only return notifications that are 7 days old or less. If the notification specified in this argument is older than 7 days, the client will return an empty `collection` response.

### Response

If the request to the client is successful, the client will return a `Notifications::Client::ReceivedTextCollection`.

You must then run either `received_texts.links` or `received_texts.collection` on the `Notifications::Client::ReceivedTextCollection` object:

- `received_texts.links` returns a hash linking to the requested requested texts (limited to 250)
- `received_texts.collection` returns an array of the required texts

A notification object will take this format:

```ruby
=> #<Notifications::Client::ReceivedTextCollection:0x007f801b07e570
 @collection:
  [#<Notifications::Client::ReceivedText:0x007f801b07e278
    @content: "hello",
    @created_at: "2017-11-22T16:49:11.007280Z",
    @id: "d22ab880-1f1d-416b-acf1-e9e4c43d7b97",
    @notify_number: "0713131313",
    @service_id: "bb86bffc-3065-4a91-8c3c-e077ad9d9a2b",
    @user_number: "447900900123">],
 @links:
  {"current"=>"http://localhost:6011/v2/received-text-messages", "next"=>"http://localhost:6011/v2/received-text-messages?older_than=025b4ec2-5ff5-43ff-b015-c50d259b9823"}>
```

If the notification specified in the `older_than` argument is older than 7 days, the client will return an empty `collection` response:

```ruby
=> #<Notifications::Client::ReceivedTextCollection:0x007f801b07e570
 @collection: [],
 @links:
  {"current"=>"http://localhost:6011/v2/received-text-messages", "next"=>"http://localhost:6011/v2/received-text-messages?older_than=025b4ec2-5ff5-43ff-b015-c50d259b9823"}>
```
