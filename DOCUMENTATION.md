# Ruby client documentation

This documentation is for developers interested in using the GOV.UK Notify Ruby client to send emails, text messages or letters.

# Set up the client

## Install the client

Run the following in the command line:

```
gem install 'notifications-ruby-client'
```

Refer to the [client changelog](https://github.com/alphagov/notifications-ruby-client/blob/master/CHANGELOG.md) for the version number and the latest updates.

## Create a new instance of the client

Add this code to your application:

```ruby
require 'notifications/client'
client = Notifications::Client.new(api_key)
```

To get an API key, [sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/) and go to the __API integration__ page. You can find more information in the [API keys](/ruby.html#api-keys) section of this documentation.

# Send a message

You can use GOV.UK Notify to send text messages, emails or letters.

## Send a text message

### Method

```ruby
smsresponse = client.send_sms(
  phone_number: "+447900900123",
  template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
)
```

### Arguments

#### phone_number (required)

The phone number of the text message recipient. This can be a UK or international number. For example:

```ruby
phone_number:"+447900900123"
```

#### template_id (required)

Sign in to [GOV.UK Notify](https://www.notifications.service.gov.uk/) and go to the __Templates__ page to find the template ID. For example:

```ruby
template_id:"f33517ff-2a88-4f6e-b855-c550268ce08a"
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

A unique identifier you can create if necessary. This reference identifies a single unique notification or a batch of notifications. For example:

```ruby
reference: "your_reference_string"
```

You can leave out this argument if you do not have a reference.

#### sms_sender_id (optional)

A unique identifier of the sender of the text message notification. You can find this information on the __Text Message sender__ settings screen.

1. Sign in to your GOV.UK Notify account.
1. Go to __Settings__.
1. If you need to change to another service, select __Switch service__ in the top right corner of the screen and select the correct one.
1. Go to the __Text Messages__ section and select __Manage__ on the __Text Message sender__ row.

You can then either:

  - copy the sender ID that you want to use and paste it into the method
  - select __Change__ to change the default sender that the service uses, and select __Save__


For example:

```ruby
sms_sender_id: "8e222534-7f05-4972-86e3-17c5d9f894e2"
```

You can leave out this argument if your service only has one text message sender, or if you want to use the default sender.

### Response

If the request to the client is successful, the client returns a `Notifications::Client:ResponseNotification` object. In the example shown in the [Method section](/ruby.html#method), the object is named `smsresponse`.

You can then call different methods on this object:

|Method|Information|Type|
|:---|:---|:---|
|`smsresponse.id`|Notification UUID|String|
|`smsresponse.reference`|`reference` argument|String|
|`smsresponse.content`|- `body`: Message body sent to the recipient<br>- `from_number`: SMS sender number of your service|Hash|
|`smsresponse.template`|Contains the `id`, `version` and `uri` of the template|Hash|
|`smsresponse.uri`|Notification URL|String|

If you are using the [test API key](/ruby.html#test), all your messages come back with a `delivered` status.

All messages sent using the [team and whitelist](#team-and-whitelist) or [live](#live) keys appear on your GOV.UK Notify dashboard.

### Error codes

If the request is not successful, the client returns a `Notifications::Client::RequestError` and an error code.

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Can't send to this recipient using a team-only API key"`<br>`]}`|Use the correct type of [API key](/ruby.html#api-keys)|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Can't send to this recipient when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode"`<br>`}]`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode)|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/ruby.html#api-keys) for more information|
|`429`|`[{`<br>`"error": "RateLimitError",`<br>`"message": "Exceeded rate limit for key type TEAM/TEST/LIVE of 3000 requests per 60 seconds"`<br>`}]`|Refer to [API rate limits](/ruby.html#api-rate-limits) for more information|
|`429`|`[{`<br>`"error": "TooManyRequestsError",`<br>`"message": "Exceeded send limits (LIMIT NUMBER) for today"`<br>`}]`|Refer to [service limits](/ruby.html#service-limits) for the limit number|
|`500`|`[{`<br>`"error": "Exception",`<br>`"message": "Internal server error"`<br>`}]`|Notify was unable to process the request, resend your notification|

## Send an email

### Method

```ruby
emailresponse = client.send_email(
  email_address: "sender@something.com",
  template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
)
```

### Arguments

#### email_address (required)

The email address of the recipient. For example:

```ruby
email_address: "sender@something.com"
```

#### template_id (required)

Sign in to [GOV.UK Notify](https://www.notifications.service.gov.uk/) and go to the __Templates__ page to find the template ID. For example:

```ruby
template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a"
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

A unique identifier you can create if necessary. This reference identifies a single unique notification or a batch of notifications. For example:

```ruby
reference: "your_reference_string"
```

You can leave out this argument if you do not have a reference.

#### email_reply_to_id (optional)

This is an email reply-to address specified by you to receive replies from your users. Your service cannot go live until you set up at least one of these email addresses.

1. Sign into your GOV.UK Notify account.
1. Go to __Settings__.
1. If you need to change to another service, select __Switch service__ in the top right corner of the screen and select the correct one.
1. Go to the __Email__ section and select __Manage__ on the __Email reply-to addresses__ row.
1. Select __Change__ to specify the email address to receive replies, and select __Save__.


For example:

```ruby
email_reply_to_id: '8e222534-7f05-4972-86e3-17c5d9f894e2'
```

You can leave out this argument if your service only has one email reply-to address, or you want to use the default email address.

### Send a document by email
Send files without the need for email attachments.

To send a document by email, add a placeholder field to the template then upload a file. The placeholder field will contain a secure link to download the document.

[Contact the GOV.UK Notify team](https://www.notifications.service.gov.uk/support) to enable this function for your service.

#### Add a placeholder field to the template

In Notify, use double brackets to add a placeholder field to the email template. For example:

"Download your document at: ((link_to_document))"

#### Upload your document

The document you upload must be a PDF file smaller than 2MB.

Pass the file object as an argument to the `Notifications.prepare_upload` helper method. Then pass the result into the personalisation argument. For example:

```ruby
File.open("file.pdf", "rb") do |f|
    ...
    personalisation: {
      first_name: "Amala",
      application_date: "2018-01-01",
      link_to_document: Notifications.prepare_upload(f),
    }
end
```

### Response

If the request to the client is successful, the client returns a `Notifications::Client:ResponseNotification` object. In the example shown in the [Method section](/ruby.html#send-an-email-method), the object is named `emailresponse`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|`emailresponse.id`|Notification UUID|String|
|`emailresponse.reference`|`reference` argument|String|
|`emailresponse.content`|- `body`: Message body<br>- `subject`: Message subject<br>- `from_email`: From email address of your service found on the **Settings** page|Hash|
|`emailresponse.template`|Contains the `id`, `version` and `uri` of the template|Hash|
|`emailresponse.uri`|Notification URL|String|

### Error codes

If the request is not successful, the client returns a `Notifications::Client::RequestError` and an error code.

|error.code|error.message|How to fix|
|:--- |:---|:---|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Can't send to this recipient using a team-only API key"`<br>`]}`|Use the correct type of [API key](/ruby.html#api-keys)|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Can't send to this recipient when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode"`<br>`}]`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode)|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Unsupported document type '{}'. Supported types are: {}"`<br>`}]`|The document you upload must be a PDF file|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Document didn't pass the virus scan"`<br>`}]`|The document you upload must be virus free|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/ruby.html#api-keys) for more information|
|`429`|`[{`<br>`"error": "RateLimitError",`<br>`"message": "Exceeded rate limit for key type TEAM/TEST/LIVE of 3000 requests per 60 seconds"`<br>`}]`|Refer to [API rate limits](/ruby.html#api-rate-limits) for more information|
|`429`|`[{`<br>`"error": "TooManyRequestsError",`<br>`"message": "Exceeded send limits (LIMIT NUMBER) for today"`<br>`}]`|Refer to [service limits](/ruby.html#service-limits) for the limit number|
|`500`|`[{`<br>`"error": "Exception",`<br>`"message": "Internal server error"`<br>`}]`|Notify was unable to process the request, resend your notification|
|-|`[{`<br>`"error": "ArgumentError",`<br>`"message": "Document is larger than 2MB")`<br>`}]`|Document size was too large, upload a smaller document|

## Send a letter

When your service first signs up to GOV.UK Notify, you’ll start in trial mode. You can only send letters in live mode. You must ask GOV.UK Notify to make your service live.

1. Sign in to [GOV.UK Notify](https://www.notifications.service.gov.uk/).
1. Select __Using Notify__.
1. Select __requesting to go live__.

### Method

```ruby
letterresponse = client.send_letter(
  template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
  personalisation: {
    address_line_1: 'The Occupier',  
    address_line_2: '123 High Street',
    postcode: 'SW14 6BH',
  },
)
```

### Arguments

#### template_id (required)

Sign in to GOV.UK Notify and go to the __Templates__ page to find the template ID. For example:

```ruby
template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a"
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
  address_line_3: 'Richmond',  # optional address field
  address_line_4: 'London', # optional address field
  address_line_5: 'Middlesex', # optional address field
  address_line_6: 'UK', # optional address field
},
```

#### reference (optional)

A unique identifier you can create if necessary. This reference identifies a single unique notification or a batch of notifications. For example:

```ruby
reference: 'your_reference_string'
```

### Response

If the request to the client is successful, the client returns a `Notifications::Client:ResponseNotification` object. In the example shown in the [Method section](/ruby.html#send-a-letter-method), the object is named `letterresponse`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|`letterresponse.id`|Notification UUID|String|
|`letterresponse.reference`|`reference` argument|String|
|`letterresponse.content`|- `body`: Letter body<br>- `subject`: Letter subject or main heading|Hash|
|`letterresponse.template`|Contains the `id`, `version` and `uri` of the template|Hash|
|`letterresponse.uri`|Notification URL|String|


### Error codes

If the request is not successful, the client returns a `Notifications::Client::RequestError` and an error code.

|error.code|error.message|How to fix|
|:--- |:---|:---|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Cannot send letters with a team api key"`<br>`]}`|Use the correct type of [API key](/ruby.html#api-keys)|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Cannot send letters when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode"`<br>`}]`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode)|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "personalisation address_line_1 is a required property"`<br>`}]`|Ensure that your template has a field for the first line of the address, refer to [personalisation](/ruby.html#personalisation-required) for more information|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/ruby.html#api-keys) for more information|
|`429`|`[{`<br>`"error": "RateLimitError",`<br>`"message": "Exceeded rate limit for key type TEAM/TEST/LIVE of 3000 requests per 60 seconds"`<br>`}]`|Refer to [API rate limits](/ruby.html#api-rate-limits) for more information|
|`429`|`[{`<br>`"error": "TooManyRequestsError",`<br>`"message": "Exceeded send limits (LIMIT NUMBER) for today"`<br>`}]`|Refer to [service limits](/ruby.html#service-limits) for the limit number|
|`500`|`[{`<br>`"error": "Exception",`<br>`"message": "Internal server error"`<br>`}]`|Notify was unable to process the request, resend your notification|

## Send a pre-compiled letter
This is an invitation-only feature. Contact the GOV.UK Notify team on the [support page](https://www.notifications.service.gov.uk/support) or through the [Slack channel](https://ukgovernmentdigital.slack.com/messages/govuk-notify) for more information.

### Method
```ruby
precompiled_letter = client.send_precompiled_letter(reference, pdf_file)
```

### Arguments

#### reference (required)
A unique identifier you create. This reference identifies a single unique notification or a batch of notifications. It must not contain any personal information such as name or postal address.

#### pdf_file (required)
The pre-compiled letter must be a PDF file.

```ruby
File.open("path/to/pdf_file", "rb") do |pdf_file|
    client.send_precompiled_letter("your reference", pdf_file)
end
```

### Response

If the request to the client is successful, the client returns a `Notifications::Client:ResponseNotification` object. In the example shown in the [Method section](/ruby.html#send-a-pre-compiled-letter-method), the object is named `precompiled_letter`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|`precompiled_letter.id`|Notification UUID|String|
|`precompiled_letter.reference`|`reference` argument|String|
|`precompiled_letter.content`|Always `nil`|nil|
|`precompiled_letter.template`|Always `nil`|nil|
|`precompiled_letter.uri`|Always `nil`|nil|

### Error codes

If the request is not successful, the client returns a `Notifications::Client::RequestError` and an error code.

|error.status_code|error.message|How to fix|
|:---|:---|:---|
|`429`|`[{`<br>`"error": "RateLimitError",`<br>`"message": "Exceeded rate limit for key type live of 10 requests per 20 seconds"`<br>`}]`|Use the correct API key. Refer to [API keys](#api-keys) for more information|
|`429`|`[{`<br>`"error": "TooManyRequestsError",`<br>`"message": "Exceeded send limits (50) for today"`<br>`}]`|Refer to [service limits](#service-limits) for the limit number|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Cannot send letters with a team api key"`<br>`]}`|Use the correct type of [API key](#api-keys)|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Cannot send precompiled letters"`<br>`]}`|This is an invitation-only feature. Contact the GOV.UK Notify team on the [support page](https://www.notifications.service.gov.uk/support) or through the [Slack channel](https://ukgovernmentdigital.slack.com/messages/govuk-notify) for more information|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Letter content is not a valid PDF"`<br>`]}`|PDF file format is required|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Cannot send letters when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode"`<br>`}]`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode)|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "reference is a required property"`<br>`}]`|Add a `reference` argument to the method call|

# Get message status

Message status depends on the type of message that you have sent.

You can only get the status of messages that are 7 days old or less.

## Status - text and email

|Status|Information|
|:---|:---|
|Created|The message is queued to be sent to the provider. The notification usually remains in this state for a few seconds.|
|Sending|The message is queued to be sent by the provider to the recipient, and GOV.UK Notify is waiting for delivery information.|
|Delivered|The message was successfully delivered.|
|Failed|This covers all failure statuses:<br>- `permanent-failure` - "The provider was unable to deliver message, email or phone number does not exist; remove this recipient from your list"<br>- `temporary-failure` - "The provider was unable to deliver message, email inbox was full or phone was turned off; you can try to send the message again"<br>- `technical-failure` - "Notify had a technical failure; you can try to send the message again"|

## Status - text only

|Status|Information|
|:---|:---|
|Pending|GOV.UK Notify received a callback from the provider but the device has not yet responded. Another callback from the provider determines the final status of the notification.|
|Sent|The text message was delivered internationally. This only applies to text messages sent to non-UK phone numbers. GOV.UK Notify may not receive additional status updates depending on the recipient's country and telecoms provider.|

## Status - letter

|Status|information|
|:---|:---|
|Failed|The only failure status that applies to letters is `technical-failure`. GOV.UK Notify had an unexpected error while sending to our printing provider.|
|Accepted|GOV.UK Notify is printing and posting the letter.|
|Received|The provider has received the letter to deliver.|

## Get the status of one message

You can only get the status of messages that are 7 days old or less.

### Method

```ruby
response = client.get_notification(id)
```

### Arguments

#### id (required)

The ID of the notification. You can find the notification ID in the response to the [original notification method call](/ruby.html#response).

You can also find it in your [GOV.UK Notify Dashboard](https://www.notifications.service.gov.uk).

1. Sign into GOV.UK Notify and select __Dashboard__.
1. Select either __emails sent__, __text messages sent__, or __letters sent__.
1. Select the relevant notification.
1. Copy the notification ID from the end of the page URL, for example `https://www.notifications.service.gov.uk/services/af90d4cb-ae88-4a7c-a197-5c30c7db423b/notification/ID`.

### Response

If the request to the client is successful, the client returns a `Notifications::Client::Notification` object. In the example shown in the [Method section](/ruby.html#get-the-status-of-one-message-method), the object is named `response`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|`response.id`|Notification UUID|String|
|`response.reference`| String supplied in `reference` argument|String|
|`response.email_address`|Recipient email address (email only)|String|
|`response.phone_number`|Recipient phone number (SMS only)|String|
|`response.line_1`|Recipient address line 1 of the address (letter only)|String|
|`response.line_2`|Recipient address line 2 of the address (letter only)|String|
|`response.line_3`|Recipient address line 3 of the address (letter only)|String|
|`response.line_4`|Recipient address line 4 of the address (letter only)|String|
|`response.line_5`|Recipient address line 5 of the address (letter only)|String|
|`response.line_6`|Recipient address line 6 of the address (letter only)|String|
|`response.postcode`|Recipient postcode (letter only)|String|
|`response.type`|Type of notification sent (sms, email or letter)|String|
|`response.status`|Notification status (sending / delivered / permanent-failure / temporary-failure / technical-failure)|String|
|`response.template`|Template UUID|String|
|`response.body`|Notification body|String|
|`response.subject`|Notification subject (email and letter)|String|
|`response.sent_at`|Date and time notification sent to provider|String|
|`response.created_at`|Date and time notification created|String|
|`response.completed_at`|Date and time notification delivered or failed|String|
|`response.created_by_name`|Name of sender if notification sent manually|String|

### Error codes

If the request is not successful, the client returns a `Notification::Client::RequestError` and an error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "id is not a valid UUID"`<br>`}]`|Check the notification ID|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/ruby.html#api-keys) for more information|
|`404`|`[{`<br>`"error": "NoResultFound",`<br>`"message": "No result found"`<br>`}]`|Check the notification ID. This error occurs if the notification is more than 7 days old.|

## Get the status of multiple messages

This API call returns one page of up to 250 messages and statuses. You can get either the most recent messages, or get older messages by specifying a particular notification ID in the `older_than` argument.

You can only get messages that are 7 days old or less.

### Method

```ruby
args = {
  template_type: 'sms',
  status: 'failed',
  reference: 'your_reference_string'
  older_than: 'e194efd1-c34d-49c9-9915-e4267e01e92e'
}
response = client.get_notifications(args)
```

You can leave out the `older_than` argument to get the 250 most recent messages.

To get older messages, pass the ID of an older notification into the `older_than` argument. This returns the next 250 oldest messages from the specified notification ID.

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
|`failed`|This returns all failure statuses:<br>- `permanent-failure`<br>- `temporary-failure`<br>- `technical-failure`|Yes|Yes||
|`permanent-failure`|The provider was unable to deliver message, email or phone number does not exist; remove this recipient from your list|Yes|Yes||
|`temporary-failure`|The provider was unable to deliver message, email inbox was full or phone was turned off; you can try to send the message again|Yes|Yes||
|`technical-failure`|Email / Text: Notify had a technical failure; you can try to send the message again. <br><br>Letter: Notify had an unexpected error while sending to our printing provider. <br><br>You can leave out this argument to ignore this filter.|Yes|Yes||
|`accepted`|Notify is printing and posting the letter|||Yes|
|`received`|The provider has received the letter to deliver|||Yes|

#### templateType (optional)

You can filter by:

* `email`
* `sms`
* `letter`

#### reference (optional)

A unique identifier you can create if necessary. This reference identifies a single unique notification or a batch of notifications. For example:

```ruby
reference: 'your_reference_string'
```

#### older_than (optional)

Input the ID of a notification into this argument. If you use this argument, the client returns the next 250 received notifications older than the given ID. For example:

```ruby
older_than: 'e194efd1-c34d-49c9-9915-e4267e01e92e'
```

If you leave out this argument, the client returns the most recent 250 notifications.

The client only returns notifications that are 7 days old or less. If the notification specified in this argument is older than 7 days, the client returns an empty response.

### Response

If the request to the client is successful, the client returns a `Notifications::Client::NotificationsCollection` object. In the example shown in the [Method section](/ruby.html#get-the-status-of-multiple-messages-method), the object is named `response`.

You must then call either the `.links` method or the `.collection` method on this object.

|Method|Information|
|:---|:---|
|`response.links`|Returns a hash linking to the requested notifications (limited to 250)|
|`response.collection`|Returns an array of the required notifications|

If you call the `collection` method on this object to return a notification array, you must then call the following methods on the notifications in this array to return information on those notifications:

|Method|Information|Type|
|:---|:---|:---|
|`response.id`|Notification UUID|String|
|`response.reference`| String supplied in `reference` argument|String|
|`response.email_address`|Recipient email address (email only)|String|
|`response.phone_number`|Recipient phone number (SMS only)|String|
|`response.line_1`|Recipient address line 1 of the address (letter only)|String|
|`response.line_2`|Recipient address line 2 of the address (letter only)|String|
|`response.line_3`|Recipient address line 3 of the address (letter only)|String|
|`response.line_4`|Recipient address line 4 of the address (letter only)|String|
|`response.line_5`|Recipient address line 5 of the address (letter only)|String|
|`response.line_6`|Recipient address line 6 of the address (letter only)|String|
|`response.postcode`|Recipient postcode (letter only)|String|
|`response.type`|Type of notification sent (sms, email or letter)|String|
|`response.status`|Notification status (sending / delivered / permanent-failure / temporary-failure / technical-failure)|String|
|`response.template`|Template UUID|String|
|`response.body`|Notification body|String|
|`response.subject`|Notification subject (email and letter)|String|
|`response.sent_at`|Date and time notification sent to provider|String|
|`response.created_at`|Date and time notification created|String|
|`response.completed_at`|Date and time notification delivered or failed|String|
|`response.created_by_name`|Name of sender if notification sent manually|String|

If the notification specified in the `older_than` argument is older than 7 days, the client returns an empty `collection` response.

### Error codes

If the request is not successful, the client returns a `Notifications::Client::RequestError` and an error code.

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "bad status is not one of [created, sending, sent, delivered, pending, failed, technical-failure, temporary-failure, permanent-failure, accepted, received]"`<br>`}]`|Contact the Notify team|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "Template type is not one of [sms, email, letter]"`<br>`}]`|Contact the Notify team|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/ruby.html#api-keys) for more information|

# Get a template

## Get a template by ID

### Method

This returns the latest version of the template.

```ruby
response = client.get_template_by_id(id)
```

### Arguments

#### id (required)

The ID of the template. Sign into GOV.UK Notify and go to the __Templates__ page to find this. For example:

```
'f33517ff-2a88-4f6e-b855-c550268ce08a'
```

### Response

If the request to the client is successful, the client returns a `Notifications::Client::Template` object. In the example shown in the [Method section](/ruby.html#get-a-template-by-id-method), the object is named `response`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|`response.id`|Template UUID|String|
|`response.name`|Template name|String|
|`response.type`|Template type (email/sms/letter)|String|
|`response.created_at`|Date and time template created|String|
|`response.updated_at`|Date and time template last updated (may be nil if version 1)|String|
|`response.created_by`|Email address of person that created the template|String|
|`response.version`|Template version|String|
|`response.body`|Template content|String|
|`response.subject`|Template subject (email and letter)|String|

### Error codes

If the request is not successful, the client returns a `Notifications::Client::RequestError` and an error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "id is not a valid UUID"`<br>`}]`|Check the notification ID|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/ruby.html#api-keys) for more information|
|`404`|`[{`<br>`"error": "NoResultFound",`<br>`"message": "No Result Found"`<br>`}]`|Check your [template ID](/ruby.html#get-a-template-by-id-arguments-id-required)|

## Get a template by ID and version

### Method

This returns the latest version of the template.

```ruby
response = client.get_template_version(id, version)
```

### Arguments

#### id (required)

The ID of the template. Sign in to GOV.UK Notify and go to the __Templates__ page to find this. For example:

```ruby
'f33517ff-2a88-4f6e-b855-c550268ce08a'
```

#### version (required)

The version number of the template.

### Response

If the request to the client is successful, the client returns a `Notifications::Client::Template` object. In the example shown in the [Method section](/ruby.html#get-a-template-by-id-and-version-method), the object is named `response`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|`response.id`|Template UUID|String|
|`response.name`|Template name|String|
|`response.type`|Template type (email/sms/letter)|String|
|`response.created_at`|Date and time template created|String|
|`response.updated_at`|Date and time template last updated (may be nil if it is the first version)|String|
|`response.created_by`|Email address of person that created the template|String|
|`response.version`|Template version|String|
|`response.body`|Template content|String|
|`response.subject`|Template subject (email and letter)|String|

### Error codes

If the request is not successful, the client returns a `Notifications::Client::RequestError` and an error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "id is not a valid UUID"`<br>`}]`|Check the notification ID|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/ruby.html#api-keys) for more information|
|`404`|`[{`<br>`"error": "NoResultFound",`<br>`"message": "No Result Found"`<br>`}]`|Check your [template ID](/ruby.html#get-a-template-by-id-and-version-arguments-id-required) and [version](/ruby.html#version-required)|

## Get all templates

### Method

This returns the latest version of all templates inside a collection object.

```ruby
args = {
  type: 'sms'
}
response = client.get_all_templates(args)
```

### Arguments

#### type (optional)

If you do not use `type`, the client returns all templates. Otherwise you can filter by:

- `email`
- `sms`
- `letter`

### Response

If the request to the client is successful, the client returns a `Notifications::Client::TemplateCollection` object. In the example shown in the [Method section](/ruby.html#get-all-templates-method), the object is named `response`.

You must then call the `.collection` method on this object to return an array of the required templates.

Once the client has returned a template array, you must then call the following methods on the templates in this array to return information on those templates.

|Method|Information|Type|
|:---|:---|:---|
|`response.id`|Template UUID|String|
|`response.name`|Template name|String|
|`response.type`|Template type (email/sms/letter)|String|
|`response.created_at`|Date and time template created|String|
|`response.updated_at`|Date and time template last updated (may be nil if it is the first version)|String|
|`response.created_by`|Email address of person that created the template|String|
|`response.version`|Template version|String|
|`response.body`|Template content|String|
|`response.subject`|Template subject (email and letter)|String|

If no templates exist for a template type or there no templates for a service, the templates array will be empty.

### Error codes

If the request is not successful, the client returns a `Notifications::Client::RequestError` and an error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "Template type is not one of [sms, email, letter]"`<br>`}]`|Contact the Notify team|

## Generate a preview template

### Method

This generates a preview version of a template.

```ruby
response = client.generate_template_preview(id)
```

The parameters in the personalisation argument must match the placeholder fields in the actual template. The API notification client ignores any extra fields in the method.

### Arguments

#### id (required)

The ID of the template. Sign into GOV.UK Notify and go to the __Templates__ page. For example:

```ruby
'f33517ff-2a88-4f6e-b855-c550268ce08a'
```

#### personalisation (optional)

If a template has placeholder fields for personalised information such as name or application date, you must provide their values in a hash. For example:

```ruby
personalisation: {
  name: "John Smith",
  ID: "300241",                      
}
```

You can leave out this argument if a template does not have any placeholder fields for personalised information.

### Response

If the request to the client is successful, the client returns a `Notifications::Client::TemplatePreview` object. In the example shown in the [Method section](/ruby.html#generate-a-preview-template-method), the object is named `response`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|`response.id`|Template UUID|String|
|`response.version`|Template version|String|
|`response.body`|Template content|String|
|`response.subject`|Template subject (email and letter)|String|
|`response.type`|Template type (sms/email/letter)|String|

### Error codes

If the request is not successful, the client returns a `Notifications::Client::RequestError` and an error code:

|error.code|error.message|How to fix|
|:---|:---|:---|
|`400`|`[{`<br>`"error": "BadRequestError",`<br>`"message": "Missing personalisation: [PERSONALISATION FIELD]"`<br>`}]`|Check that the personalisation arguments in the method match the placeholder fields in the template|
|`400`|`[{`<br>`"error": "NoResultFound",`<br>`"message": "No result found"`<br>`}]`|Check the [template ID](/ruby.html#generate-a-preview-template-arguments-id-required)|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/ruby.html#api-keys) for more information|

# Get received text messages

This API call returns one page of up to 250 received text messages. You can get either the most recent messages, or get older messages by specifying a particular notification ID in the `older_than` argument.

You can only get the status of messages that are 7 days old or less.

### Method

```ruby
args = {
  older_than: 'e194efd1-c34d-49c9-9915-e4267e01e92e'
}
response = client.get_received_texts(args)
```

To get older messages, pass the ID of an older notification into the `older_than` argument. This returns the next oldest messages from the specified notification ID.

If you leave out the `older_than` argument, the client returns the most recent 250 notifications.

### Arguments

#### older_than (optional)

Input the ID of a received text message into this argument. If you use this argument, the client returns the next 250 received text messages older than the given ID. For example:

```ruby
older_than: '8e222534-7f05-4972-86e3-17c5d9f894e2'
```

If you leave out the `older_than` argument, the client returns the most recent 250 notifications.

The client only returns notifications that are 7 days old or less. If the notification specified in this argument is older than 7 days, the client returns an empty `collection` response.

### Response

If the request to the client is successful, the client returns a `Notifications::Client::ReceivedTextCollection` object. In the example shown in the [Method section](/ruby.html#get-received-text-messages-method), the object is named `response`.

You must then call either the `.links` method or the `.collection` method on this object.

|Method|Information|
|:---|:---|
|`response.links`|Returns a hash linking to the requested texts (limited to 250)|
|`response.collection`|Returns an array of the required texts|

If you call the `collection` method on this object to return an array, you must then call the following methods on the received texts in this array to return information on those texts:

|Method|Information|Type|
|:---|:---|:---|
|`response.id`|Received text UUID|String|
|`response.created_at`|Date and time of received text|String|
|`response.content`|Received text content|String|
|`response.notify_number`|Number that received text was sent to|String|
|`response.service_id`|Received text service ID|String|
|`response.user_number`|Number that received text was sent from|String|

If the notification specified in the `older_than` argument is older than 7 days, the client returns an empty `collection` response.

### Error codes

If the request is not successful, the client returns a `Notifications::Client::RequestError` and an error code.

|error.code|error.message|How to fix|
|:---|:---|:---|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Error: Your system clock must be accurate to within 30 seconds"`<br>`}]`|Check your system clock|
|`403`|`[{`<br>`"error": "AuthError",`<br>`"message": "Invalid token: signature, api token not found"`<br>`}]`|Use the correct API key. Refer to [API keys](/ruby.html#api-keys) for more information|
