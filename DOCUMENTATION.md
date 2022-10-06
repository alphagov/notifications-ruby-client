# Ruby client documentation

This documentation is for developers interested in using the GOV.UK Notify Ruby client to send emails, text messages or letters.

## Set up the client

### Install the client

Run the following in the command line:

```
gem install 'notifications-ruby-client'
```

Refer to the [client changelog](https://github.com/alphagov/notifications-ruby-client/blob/master/CHANGELOG.md) for the version number and the latest updates.

### Create a new instance of the client

Add this code to your application:

```ruby
require 'notifications/client'
client = Notifications::Client.new(api_key)
```

To get an API key, [sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in) and go to the __API integration__ page. You can find more information in the [API keys](#api-keys) section of this documentation.

## Send a message

You can use GOV.UK Notify to send text messages, emails or letters.

### Send a text message

#### Method

```ruby
smsresponse = client.send_sms(
  phone_number: "+447900900123",
  template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
)
```

#### Arguments

##### phone_number (required)

The phone number of the text message recipient. This can be a UK or international number. For example:

```ruby
phone_number:"+447900900123"
```

##### template_id (required)

To find the template ID:

1. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in).
1. Go to the __Templates__ page and select the relevant template.
1. Select __Copy template ID to clipboard__.

For example:

```ruby
template_id:"f33517ff-2a88-4f6e-b855-c550268ce08a"
```

##### personalisation (optional)

If a template has placeholder fields for personalised information such as name or reference number, you must provide their values in a hash. For example:

```ruby
personalisation: {
  name: "John Smith",
  ID: "300241",
}
```

You can leave out this argument if a template does not have any placeholder fields for personalised information.

##### reference (optional)

A unique identifier you can create if necessary. This reference identifies a single unique notification or a batch of notifications. It must not contain any personal information such as name or postal address. For example:

```ruby
reference: "your_reference_string"
```

You can leave out this argument if you do not have a reference.

##### sms_sender_id (optional)

A unique identifier of the sender of the text message notification.

To find the text message sender:

1. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in).
1. Go to the __Settings__ page.
1. In the __Text Messages__ section, select __Manage__ on the __Text Message sender__ row.

You can then either:

  - copy the sender ID that you want to use and paste it into the method
  - select __Change__ to change the default sender that the service uses, and select __Save__


For example:

```ruby
sms_sender_id: "8e222534-7f05-4972-86e3-17c5d9f894e2"
```

You can leave out this argument if your service only has one text message sender, or if you want to use the default sender.

#### Response

If the request to the client is successful, the client returns a `Notifications::Client:ResponseNotification` object. In the example shown in the [Method section](#method), the object is named `smsresponse`.

You can then call different methods on this object:

|Method|Information|Type|
|:---|:---|:---|
|#`smsresponse.id`|Notification UUID|String|
|#`smsresponse.reference`|`reference` argument|String|
|#`smsresponse.content`|- `body`: Message body sent to the recipient<br>- `from_number`: SMS sender number of your service|Hash|
|#`smsresponse.template`|Contains the `id`, `version` and `uri` of the template|Hash|
|#`smsresponse.uri`|Notification URL|String|

If you are using the [test API key](#test), all your messages come back with a `delivered` status.

All messages sent using the [team and guest list](#team-and-guest-list) or [live](#live) keys appear on your GOV.UK Notify dashboard.

#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:---|:---|:---|:---|
|`400`|`BadRequestError: Can't send to this recipient using a team-only API key`|`BadRequestError`|Use the correct type of [API key](#api-keys)|
|`400`|`BadRequestError: Can't send to this recipient when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode`|`BadRequestError`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode)|
|`403`|`AuthError: Error: Your system clock must be accurate to within 30 seconds`|`AuthError`|Check your system clock|
|`403`|`AuthError: Invalid token: API key not found`|`AuthError`|Use the correct API key. Refer to [API keys](#api-keys) for more information|
|`429`|`RateLimitError: Exceeded rate limit for key type TEAM/TEST/LIVE of 3000 requests per 60 seconds`|`RateLimitError`|Refer to [API rate limits](#rate-limits) for more information|
|`429`|`TooManyRequestsError: Exceeded send limits (LIMIT NUMBER) for today`|`ClientError`|Refer to [service limits](#daily-limits) for the limit number|
|`500`|`Exception: Internal server error`|`ServerError`|Notify was unable to process the request, resend your notification|

### Send an email

#### Method

```ruby
emailresponse = client.send_email(
  email_address: "sender@something.com",
  template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
)
```

#### Arguments

##### email_address (required)

The email address of the recipient. For example:

```ruby
email_address: "sender@something.com"
```

##### template_id (required)

To find the template ID:

1. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in).
1. Go to the __Templates__ page and select the relevant template.
1. Select __Copy template ID to clipboard__.

For example:

```ruby
template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a"
```

##### personalisation (optional)

If a template has placeholder fields for personalised information such as name or reference number, you must provide their values in a hash. For example:

```ruby
personalisation: {
  name: "John Smith",
  year: "2016"
}
```

You can leave out this argument if a template does not have any placeholder fields for personalised information.

##### reference (optional)

A unique identifier you can create if necessary. This reference identifies a single unique notification or a batch of notifications. It must not contain any personal information such as name or postal address. For example:

```ruby
reference: "your_reference_string"
```

You can leave out this argument if you do not have a reference.

##### email_reply_to_id (optional)

This is an email address specified by you to receive replies from your users. You must add at least one reply-to email address before your service can go live.

To add a reply-to email address:

1. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in).
1. Go to the __Settings__ page.
1. In the __Email__ section, select __Manage__ on the __Reply-to email addresses__ row.
1. Select __Add reply-to address__.
1. Enter the email address you want to use, and select __Add__.

For example:

```ruby
email_reply_to_id: '8e222534-7f05-4972-86e3-17c5d9f894e2'
```

You can leave out this argument if your service only has one email reply-to address, or you want to use the default email address.

### Send a file by email

To send a file by email, add a placeholder to the template then upload a file. The placeholder will contain a secure link to download the file.

The links are unique and unguessable. GOV.UK Notify cannot access or decrypt your file.

Your file will be available to download for a default period of 78 weeks (18 months). From 29 March 2023 we will reduce this to 26 weeks (6 months) for all new files. Files sent before 29 March will not be affected.

To help protect your files you can also:

* ask recipients to confirm their email address before downloading
* choose the length of time that a file is available to download

To turn these features on or off, you will need version 5.4.0 of the Ruby client library or a more recent version.

#### Add contact details to the file download page

1. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in).
1. Go to the __Settings__ page.
1. In the __Email__ section, select __Manage__ on the __Send files by email__ row.
1. Enter the contact details you want to use, and select __Save__.

#### Add a placeholder to the template

1. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in).
1. Go to the __Templates__ page and select the relevant email template.
1. Select __Edit__.
1. Add a placeholder to the email template using double brackets. For example: "Download your file at: ((link_to_file))"

Your email should also tell recipients how long the file will be available to download.

#### Upload your file

You can upload PDF, CSV, .odt, .txt, .rtf, .xlsx and MS Word Document files. Your file must be smaller than 2MB. [Contact the GOV.UK Notify team](https://www.notifications.service.gov.uk/support/ask-question-give-feedback) if you need to send other file types.

1. Pass the file object as an argument to the `Notifications.prepare_upload` helper method.
1. Pass the result into the personalisation argument.

For example:

```ruby
File.open("file.pdf", "rb") do |f|
    ...
    personalisation: {
      first_name: "Amala",
      application_date: "2018-01-01",
      link_to_file: Notifications.prepare_upload(f),
    }
end
```

##### CSV Files

Uploads for CSV files should use the `is_csv` parameter on the `prepare_upload()` helper method.  For example:

```ruby
File.open("file.csv", "rb") do |f|
    ...
    personalisation: {
      first_name: "Amala",
      application_date: "2018-01-01",
      link_to_file: Notifications.prepare_upload(f, is_csv=true),
    }
end
```

#### Ask recipients to confirm their email address before they can download the file

This new security feature is optional. You should use it if you send files that are sensitive - for example, because they contain personal information about your users.

When a recipient clicks the link in the email you’ve sent them, they have to enter their email address. Only someone who knows the recipient’s email address can download the file.

From 29 March 2023, we will turn this feature on by default for every file you send. Files sent before 29 March will not be affected.

##### Turn on email address check

To use this feature before 29 March 2023 you will need version 5.4.0 of the Ruby client library, or a more recent version.

To make the recipient confirm their email address before downloading the file, set the `confirm_email_before_download` flag to `true`.

You will not need to do this after 29 March.

```ruby
File.open("file.pdf", "rb") do |f|
    ...
    personalisation: {
      first_name: "Amala",
      application_date: "2018-01-01",
      link_to_file: Notifications.prepare_upload(f, confirm_email_before_download: true),
    }
end
```

##### Turn off email address check (not recommended)

If you do not want to use this feature after 29 March 2023, you can turn it off on a file-by-file basis.

To do this you will need version 5.4.0 of the Ruby client library, or a more recent version.

You should not turn this feature off if you send files that contain:

* personally identifiable information
* commercially sensitive information
* information classified as ‘OFFICIAL’ or ‘OFFICIAL-SENSITIVE’ under the [Government Security Classifications](https://www.gov.uk/government/publications/government-security-classifications) policy

To let the recipient download the file without confirming their email address, set the `confirm_email_before_download` flag to `false`.



```ruby
File.open("file.pdf", "rb") do |f|
    ...
    personalisation: {
      first_name: "Amala",
      application_date: "2018-01-01",
      link_to_file: Notifications.prepare_upload(f, confirm_email_before_download: false),
    }
end
```

#### Choose the length of time that a file is available to download

Set the number of weeks you want the file to be available using the `retention_period` key.

You can choose any value between 1 week and 78 weeks.

To use this feature will need version 5.4.0 of the Ruby client library, or a more recent version.

If you do not choose a value, the file will be available for the default period of 78 weeks (18 months).

```ruby
File.open("file.pdf", "rb") do |f|
    ...
    personalisation: {
      first_name: "Amala",
      application_date: "2018-01-01",
      link_to_file: Notifications.prepare_upload(f, retention_period: '52 weeks'),
    }
end
```

#### Response

If the request to the client is successful, the client returns a `Notifications::Client:ResponseNotification` object. In the example shown in the [Method section](#send-an-email-method), the object is named `emailresponse`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|#`emailresponse.id`|Notification UUID|String|
|#`emailresponse.reference`|`reference` argument|String|
|#`emailresponse.content`|- `body`: Message body<br>- `subject`: Message subject<br>- `from_email`: From email address of your service found on the **Settings** page|Hash|
|#`emailresponse.template`|Contains the `id`, `version` and `uri` of the template|Hash|
|#`emailresponse.uri`|Notification URL|String|

#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:--- |:---|:---|:---|
|`400`|`BadRequestError: Can't send to this recipient using a team-only API key`|`BadRequestError`|Use the correct type of [API key](#api-keys)|
|`400`|`BadRequestError: Can't send to this recipient when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode`|`BadRequestError`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode)|
|`400`|`BadRequestError: Unsupported file type '(FILE TYPE)'. Supported types are: '(ALLOWED TYPES)'`|`BadRequestError`|Wrong file type. You can only upload .pdf, .csv, .txt, .doc, .docx, .xlsx, .rtf or .odt files|
|`400`|`BadRequestError: Unsupported value for retention_period '(PERIOD)'. Supported periods are from 1 to 78 weeks.`|Choose a period between 1 and 78 weeks|
|`400`|`BadRequestError: Unsupported value for confirm_email_before_download: '(VALUE)'. Use a boolean true or false value.`|Use either true or false|
|`400`|`BadRequestError: File did not pass the virus scan`|`BadRequestError`|The file contains a virus|
|`400`|`BadRequestError: Send files by email has not been set up - add contact details for your service at https://www.notifications.service.gov.uk/services/(SERVICE ID)/service-settings/send-files-by-email`|`BadRequestError`|See how to [add contact details to the file download page](#add-contact-details-to-the-file-download-page)|
|`400`|`BadRequestError: Can only send a file by email` | `BadRequestError`|Make sure you are using an email template|
|`403`|`AuthError: Error: Your system clock must be accurate to within 30 seconds`|`AuthError`|Check your system clock|
|`403`|`AuthError: Invalid token: API key not found`|`AuthError`|Use the correct API key. Refer to [API keys](#api-keys) for more information|
|`429`|`RateLimitError: Exceeded rate limit for key type TEAM/TEST/LIVE of 3000 requests per 60 seconds`|`RateLimitError`|Refer to [API rate limits](#rate-limits) for more information|
|`429`|`TooManyRequestsError: Exceeded send limits (LIMIT NUMBER) for today`|`RateLimitError`|Refer to [service limits](#daily-limits) for the limit number|
|`500`|`Exception: Internal server error`|`ServerError`|Notify was unable to process the request, resend your notification|
|-|`ArgumentError: File is larger than 2MB")`|-|The file is too big. Files must be smaller than 2MB|

### Send a letter

When you add a new service it will start in [trial mode](https://www.notifications.service.gov.uk/features/trial-mode). You can only send letters when your service is live.

To send Notify a request to go live:

1. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in).
1. Go to the __Settings__ page.
1. In the __Your service is in trial mode__ section, select __request to go live__.

#### Method

```ruby
letterresponse = client.send_letter(
  template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a",
  personalisation: {
    address_line_1: 'The Occupier',
    address_line_2: '123 High Street',
    address_line_3: 'SW14 6BH',
  },
)
```

#### Arguments

##### template_id (required)

To find the template ID:

1. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in).
1. Go to the __Templates__ page and select the relevant template.
1. Select __Copy template ID to clipboard__.

For example:

```ruby
template_id: "f33517ff-2a88-4f6e-b855-c550268ce08a"
```

##### personalisation (required)

The personalisation argument always contains the following parameters for the letter recipient’s address:

- `address_line_1`
- `address_line_2`
- `address_line_3`
- `address_line_4`
- `address_line_5`
- `address_line_6`
- `address_line_7`

The address must have at least 3 lines.

The last line needs to be a real UK postcode or the name of a country outside the UK.

Notify checks for international addresses and will automatically charge you the correct postage.

The `postcode` personalisation argument has been replaced. If your template still uses `postcode`, Notify will treat it as the last line of the address.

Any other placeholder fields included in the letter template also count as required parameters. You must provide their values in a hash. For example:


```ruby
personalisation: {
  address_line_1: 'The Occupier',  # mandatory address field
  address_line_2: '123 High Street', # mandatory address field
  address_line_3: 'SW14 6BH',  # mandatory address field
  name: 'John Smith', # field from template
  application_date: '2018-01-01' # field from template
},
```

##### reference (optional)

A unique identifier you can create if necessary. This reference identifies a single unique notification or a batch of notifications. It must not contain any personal information such as name or postal address. For example:

```ruby
reference: 'your_reference_string'
```

#### Response

If the request to the client is successful, the client returns a `Notifications::Client:ResponseNotification` object. In the example shown in the [Method section](#send-a-letter-method), the object is named `letterresponse`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|#`letterresponse.id`|Notification UUID|String|
|#`letterresponse.reference`|`reference` argument|String|
|#`letterresponse.content`|- `body`: Letter body<br>- `subject`: Letter subject or main heading|Hash|
|#`letterresponse.template`|Contains the `id`, `version` and `uri` of the template|Hash|
|#`letterresponse.uri`|Notification URL|String|


#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:--- |:---|:---|:---|
|`400`|`BadRequestError: Cannot send letters with a team api key`|`BadRequestError`|Use the correct type of [API key](#api-keys).|
|`400`|`BadRequestError: Cannot send letters when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode`|`BadRequestError`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode).|
|`400`|`ValidationError: personalisation address_line_1 is a required property`|`BadRequestError`|Ensure that your template has a field for the first line of the address, refer to [personalisation](#personalisation-required) for more information.|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "Must be a real UK postcode"`<br>`}]`|Ensure that the value for the last line of the address is a real UK postcode.|
|`400`|`[{`<br>`"error": "ValidationError",`<br>`"message": "Last line of address must be a real UK postcode or another country"`<br>`}]`|Ensure that the value for the last line of the address is a real UK postcode or the name of a country outside the UK.|
|`403`|`AuthError: Error: Your system clock must be accurate to within 30 seconds`|`AuthError`|Check your system clock.|
|`403`|`AuthError: Invalid token: API key not found`|`AuthError`|Use the correct API key. Refer to [API keys](#api-keys) for more information.|
|`429`|`RateLimitError: Exceeded rate limit for key type TEAM/TEST/LIVE of 3000 requests per 60 seconds`|`RateLimitError`|Refer to [API rate limits](#rate-limits) for more information.|
|`429`|`TooManyRequestsError: Exceeded send limits (LIMIT NUMBER) for today`|`RateLimitError`|Refer to [service limits](#daily-limits) for the limit number.|
|`500`|`Exception: Internal server error`|`ServerError`|Notify was unable to process the request, resend your notification.|

### Send a precompiled letter

#### Method
```ruby
precompiled_letter = client.send_precompiled_letter(reference, pdf_file)
```

#### Arguments

##### reference (required)
A unique identifier you create. This reference identifies a single unique notification or a batch of notifications. It must not contain any personal information such as name or postal address.

##### pdf_file (required)

The precompiled letter must be a PDF file which meets [the GOV.UK Notify letter specification](https://www.notifications.service.gov.uk/using-notify/guidance/letter-specification).

```ruby
File.open("path/to/pdf_file", "rb") do |pdf_file|
    client.send_precompiled_letter("your reference", pdf_file)
end
```

##### postage (optional)

You can choose first or second class postage for your precompiled letter. Set the value to `first` for first class, or `second` for second class. If you do not pass in this argument, the postage will default to second class.


#### Response

If the request to the client is successful, the client returns a `Notifications::Client:ResponsePrecompiledLetter` object. In the example shown in the [Method section](#send-a-precompiled-letter-method), the object is named `precompiled_letter`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|#`precompiled_letter.id`|Notification UUID|String|
|#`precompiled_letter.reference`|`reference` argument|String|
|#`precompiled_letter.postage`|`postage` argument|String|


#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.status_code|error.message|class|How to fix|
|:---|:---|:---|:---|
|`400`|`BadRequestError: Cannot send letters with a team api key`|`BadRequestError`|Use the correct type of [API key](#api-keys)|
|`400`|`BadRequestError: Letter content is not a valid PDF`|`BadRequestError`|PDF file format is required|
|`400`|`BadRequestError: Cannot send letters when service is in trial mode - see https://www.notifications.service.gov.uk/trial-mode`|`BadRequestError`|Your service cannot send this notification in [trial mode](https://www.notifications.service.gov.uk/features/using-notify#trial-mode)|
|`400`|`ValidationError: reference is a required property`|`BadRequestError`|Add a `reference` argument to the method call|
|`400`|`ValidationError: postage invalid. It must be either first or second.`|`BadRequestError`|Change the value of `postage` argument in the method call to either 'first' or 'second'|
|`429`|`RateLimitError: Exceeded rate limit for key type live of 10 requests per 20 seconds`|`RateLimitError`|Use the correct API key. Refer to [API keys](#api-keys) for more information|
|`429`|`TooManyRequestsError: Exceeded send limits (50) for today`|`RateLimitError`|Refer to [service limits](#daily-limits) for the limit number|

## Get message status



### Get the status of one message

You can only get the status of messages sent within the retention period. The default retention period is 7 days.

#### Method

```ruby
response = client.get_notification(id)
```

#### Arguments

##### id (required)

The ID of the notification. To find the notification ID, you can either:

* check the response to the [original notification method call](#response)
* [sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in) and go to the __API integration__ page

#### Response

If the request to the client is successful, the client returns a `Notifications::Client::Notification` object. In the example shown in the [Method section](#get-the-status-of-one-message-method), the object is named `response`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|#`response.id`|Notification UUID|String|
|#`response.reference`| String supplied in `reference` argument|String|
|#`response.email_address`|Recipient email address (email only)|String|
|#`response.phone_number`|Recipient phone number (SMS only)|String|
|#`response.line_1`|Recipient address line 1 of the address (letter only)|String|
|#`response.line_2`|Recipient address line 2 of the address (letter only)|String|
|#`response.line_3`|Recipient address line 3 of the address (letter only)|String|
|#`response.line_4`|Recipient address line 4 of the address (letter only)|String|
|#`response.line_5`|Recipient address line 5 of the address (letter only)|String|
|#`response.line_6`|Recipient address line 6 of the address (letter only)|String|
|#`response.line_7`|Recipient address line 7 of the address (letter only)|String|
|#`response.postage`|Postage class of the notification sent (letter only)|String|
|#`response.type`|Type of notification sent (sms, email or letter)|String|
|#`response.status`|Notification status (sending / delivered / permanent-failure / temporary-failure / technical-failure)|String|
|#`response.template`|Template UUID|String|
|#`response.body`|Notification body|String|
|#`response.subject`|Notification subject (email and letter)|String|
|#`response.sent_at`|Date and time notification sent to provider|String|
|#`response.created_at`|Date and time notification created|String|
|#`response.completed_at`|Date and time notification delivered or failed|String|
|#`response.created_by_name`|Name of sender if notification sent manually|String|

#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:---|:---|:---|:---|
|`400`|`ValidationError: id is not a valid UUID`|`BadRequestError`|Check the notification ID|
|`403`|`AuthError: Error: Your system clock must be accurate to within 30 seconds`|`AuthError`|Check your system clock|
|`403`|`AuthError: Invalid token: API key not found`|`AuthError`|Use the correct API key. Refer to [API keys](#api-keys) for more information|
|`404`|`NoResultFound: No result found`|`NotFoundError`|Check the notification ID. This error occurs if the notification is more than 7 days old.|

### Get the status of multiple messages

This API call returns one page of up to 250 messages and statuses. You can get either the most recent messages, or get older messages by specifying a particular notification ID in the `older_than` argument.

You can only get messages that are 7 days old or newer.

#### Method

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

#### Arguments

You can leave out these arguments to ignore these filters.

##### status (optional)

You can filter by each:

* [email status](#email-status-descriptions)
* [text message status](#text-message-status-descriptions)
* [letter status](#letter-status-descriptions)
* [precompiled letter status](#precompiled-letter-status-descriptions)

You can leave out this argument to ignore this filter.

##### templateType (optional)

You can filter by:

* `email`
* `sms`
* `letter`

##### reference (optional)

A unique identifier you can create if necessary. This reference identifies a single unique notification or a batch of notifications. It must not contain any personal information such as name or postal address. For example:

```ruby
reference: 'your_reference_string'
```

##### older_than (optional)

Input the ID of a notification into this argument. If you use this argument, the client returns the next 250 received notifications older than the given ID. For example:

```ruby
older_than: 'e194efd1-c34d-49c9-9915-e4267e01e92e'
```

If you leave out this argument, the client returns the most recent 250 notifications.

The client only returns notifications that are 7 days old or newer. If the notification specified in this argument is older than 7 days, the client returns an empty response.

#### Response

If the request to the client is successful, the client returns a `Notifications::Client::NotificationsCollection` object. In the example shown in the [Method section](#get-the-status-of-multiple-messages-method), the object is named `response`.

You must then call either the `.links` method or the `.collection` method on this object.

|Method|Information|
|:---|:---|
|#`response.links`|Returns a hash linking to the requested notifications (limited to 250)|
|#`response.collection`|Returns an array of the required notifications|

If you call the `collection` method on this object to return a notification array, you must then call the following methods on the notifications in this array to return information on those notifications:

|Method|Information|Type|
|:---|:---|:---|
|#`response.id`|Notification UUID|String|
|#`response.reference`| String supplied in `reference` argument|String|
|#`response.email_address`|Recipient email address (email only)|String|
|#`response.phone_number`|Recipient phone number (SMS only)|String|
|#`response.line_1`|Recipient address line 1 of the address (letter only)|String|
|#`response.line_2`|Recipient address line 2 of the address (letter only)|String|
|#`response.line_3`|Recipient address line 3 of the address (letter only)|String|
|#`response.line_4`|Recipient address line 4 of the address (letter only)|String|
|#`response.line_5`|Recipient address line 5 of the address (letter only)|String|
|#`response.line_6`|Recipient address line 6 of the address (letter only)|String|
|#`response.postcode`|Recipient postcode (letter only)|String|
|#`response.type`|Type of notification sent (sms, email or letter)|String|
|#`response.status`|Notification status (sending / delivered / permanent-failure / temporary-failure / technical-failure)|String|
|#`response.template`|Template UUID|String|
|#`response.body`|Notification body|String|
|#`response.subject`|Notification subject (email and letter)|String|
|#`response.sent_at`|Date and time notification sent to provider|String|
|#`response.created_at`|Date and time notification created|String|
|#`response.completed_at`|Date and time notification delivered or failed|String|
|#`response.created_by_name`|Name of sender if notification sent manually|String|

If the notification specified in the `older_than` argument is older than 7 days, the client returns an empty `collection` response.

#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:---|:---|:---|:---|
|`400`|`ValidationError: bad status is not one of [created, sending, sent, delivered, pending, failed, technical-failure, temporary-failure, permanent-failure, accepted, received]`|`BadRequestError`|Contact the GOV.UK Notify team|
|`400`|`ValidationError: Template type is not one of [sms, email, letter]`|`BadRequestError`|Contact the GOV.UK Notify team|
|`403`|`AuthError: Error: Your system clock must be accurate to within 30 seconds`|`AuthError`|Check your system clock|
|`403`|`AuthError: Invalid token: API key not found`|`AuthError`|Use the correct API key. Refer to [API keys](#api-keys) for more information|

### Email status descriptions

|Status|Description|
|:---|:---|
|#`created`|GOV.UK Notify has placed the message in a queue, ready to be sent to the provider. It should only remain in this state for a few seconds.|
|#`sending`|GOV.UK Notify has sent the message to the provider. The provider will try to deliver the message to the recipient for up to 72 hours. GOV.UK Notify is waiting for delivery information.|
|#`delivered`|The message was successfully delivered.|
|#`permanent-failure`|The provider could not deliver the message because the email address was wrong. You should remove these email addresses from your database.|
|#`temporary-failure`|The provider could not deliver the message. This can happen when the recipient’s inbox is full or their anti-spam filter rejects your email. [Check your content does not look like spam](https://www.gov.uk/service-manual/design/sending-emails-and-text-messages#protect-your-users-from-spam-and-phishing) before you try to send the message again.|
|#`technical-failure`|Your message was not sent because there was a problem between Notify and the provider.<br>You’ll have to try sending your messages again.|

### Text message status descriptions

|Status|Description|
|:---|:---|
|#`created`|GOV.UK Notify has placed the message in a queue, ready to be sent to the provider. It should only remain in this state for a few seconds.|
|#`sending`|GOV.UK Notify has sent the message to the provider. The provider will try to deliver the message to the recipient for up to 72 hours. GOV.UK Notify is waiting for delivery information.|
|#`pending`|GOV.UK Notify is waiting for more delivery information.<br>GOV.UK Notify received a callback from the provider but the recipient’s device has not yet responded. Another callback from the provider determines the final status of the text message.|
|#`sent`|The message was sent to an international number. The mobile networks in some countries do not provide any more delivery information. The GOV.UK Notify website displays this status as 'Sent to an international number'.|
|#`delivered`|The message was successfully delivered.|
|#`permanent-failure`|The provider could not deliver the message. This can happen if the phone number was wrong or if the network operator rejects the message. If you’re sure that these phone numbers are correct, you should [contact GOV.UK Notify support](https://www.notifications.service.gov.uk/support). If not, you should remove them from your database. You’ll still be charged for text messages that cannot be delivered.
|#`temporary-failure`|The provider could not deliver the message. This can happen when the recipient’s phone is off, has no signal, or their text message inbox is full. You can try to send the message again. You’ll still be charged for text messages to phones that are not accepting messages.|
|#`technical-failure`|Your message was not sent because there was a problem between Notify and the provider.<br>You’ll have to try sending your messages again. You will not be charged for text messages that are affected by a technical failure.|

### Letter status descriptions

|Status|Description|
|:---|:---|
|#`accepted`|GOV.UK Notify has sent the letter to the provider to be printed.|
|#`received`|The provider has printed and dispatched the letter.|
|#`cancelled`|Sending cancelled. The letter will not be printed or dispatched.|
|#`technical-failure`|GOV.UK Notify had an unexpected error while sending the letter to our printing provider.|
|#`permanent-failure`|The provider cannot print the letter. Your letter will not be dispatched.|

### Precompiled letter status descriptions

|Status|Description|
|:---|:---|
|#`accepted`|GOV.UK Notify has sent the letter to the provider to be printed.|
|#`received`|The provider has printed and dispatched the letter.|
|#`cancelled`|Sending cancelled. The letter will not be printed or dispatched.|
|#`pending-virus-check`|GOV.UK Notify has not completed a virus scan of the precompiled letter file.|
|#`virus-scan-failed`|GOV.UK Notify found a potential virus in the precompiled letter file.|
|#`validation-failed`|Content in the precompiled letter file is outside the printable area. See the [GOV.UK Notify letter specification](https://www.notifications.service.gov.uk/using-notify/guidance/letter-specification) for more information.|
|#`technical-failure`|GOV.UK Notify had an unexpected error while sending the letter to our printing provider.|
|#`permanent-failure`|The provider cannot print the letter. Your letter will not be dispatched.|


### Get a PDF for a letter notification

#### Method

This returns the pdf contents of a letter notification.

```ruby
pdf_file = client.get_pdf_for_letter(
  'f33517ff-2a88-4f6e-b855-c550268ce08a' # notification id (required)
)
```

#### Arguments

##### id (required)

The ID of the notification. To find the notification ID, you can either:

* check the response to the [original notification method call](#get-the-status-of-one-message-response)
* [sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in) and go to the __API integration__ page

#### Response

If the request to the client is successful, the client will return a `string` containing the raw PDF data.

#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:---|:---|:---|:---|
|`400`|`ValidationError: id is not a valid UUID`|`BadRequestError`|Check the notification ID|
|`400`|`PDFNotReadyError: PDF not available yet, try again later`|`BadRequestError`|Wait for the notification to finish processing. This usually takes a few seconds|
|`400`|`BadRequestError: File did not pass the virus scan`|`BadRequestError`|You cannot retrieve the contents of a letter notification that contains a virus|
|`400`|`BadRequestError: PDF not available for letters in technical-failure`|`BadRequestError`|You cannot retrieve the contents of a letter notification in technical-failure|
|`400`|`ValidationError: Notification is not a letter`|`BadRequestError`|Check that you are looking up the correct notification|
|`403`|`AuthError: Error: Your system clock must be accurate to within 30 seconds`|`BadRequestError`|Check your system clock|
|`403`|`AuthError: Invalid token: API key not found`|`BadRequestError`|Use the correct API key. Refer to [API keys](#api-keys) for more information|
|`404`|`NoResultFound: No result found`|`BadRequestError`|Check the notification ID|


## Get a template

### Get a template by ID

#### Method

This returns the latest version of the template.

```ruby
response = client.get_template_by_id(id)
```

#### Arguments

##### id (required)

The ID of the template. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in) and go to the __Templates__ page to find it. For example:

```
'f33517ff-2a88-4f6e-b855-c550268ce08a'
```

#### Response

If the request to the client is successful, the client returns a `Notifications::Client::Template` object. In the example shown in the [Method section](#get-a-template-by-id-method), the object is named `response`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|#`response.id`|Template UUID|String|
|#`response.name`|Template name|String|
|#`response.type`|Template type (email/sms/letter)|String|
|#`response.created_at`|Date and time template created|String|
|#`response.updated_at`|Date and time template last updated (may be nil if version 1)|String|
|#`response.created_by`|Email address of person that created the template|String|
|#`response.version`|Template version|String|
|#`response.body`|Template content|String|
|#`response.subject`|Template subject (email and letter)|String|
|#`response.letter_contact_block`|Template letter contact block (letter)|String|

#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:---|:---|:---|:---|
|`400`|`ValidationError: id is not a valid UUID`|`BadRequestError`|Check the notification ID|
|`403`|`AuthError: Error: Your system clock must be accurate to within 30 seconds`|`AuthError`|Check your system clock|
|`403`|`AuthError: Invalid token: API key not found`|`AuthError`|Use the correct API key. Refer to [API keys](#api-keys) for more information|
|`404`|`NoResultFound: No Result Found`|`NotFoundError`|Check your [template ID](#get-a-template-by-id-arguments-id-required)|

### Get a template by ID and version

#### Method

```ruby
response = client.get_template_version(id, version)
```

#### Arguments

##### id (required)

The ID of the template. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in) and go to the __Templates__ page to find it. For example:

```ruby
'f33517ff-2a88-4f6e-b855-c550268ce08a'
```

##### version (required)

The version number of the template.

#### Response

If the request to the client is successful, the client returns a `Notifications::Client::Template` object. In the example shown in the [Method section](#get-a-template-by-id-and-version-method), the object is named `response`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|#`response.id`|Template UUID|String|
|#`response.name`|Template name|String|
|#`response.type`|Template type (email/sms/letter)|String|
|#`response.created_at`|Date and time template created|String|
|#`response.updated_at`|Date and time template last updated (may be nil if it is the first version)|String|
|#`response.created_by`|Email address of person that created the template|String|
|#`response.version`|Template version|String|
|#`response.body`|Template content|String|
|#`response.subject`|Template subject (email and letter)|String|
|#`response.letter_contact_block`|Template letter contact block (letter)|String|

#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:---|:---|:---|:---|
|`400`|`ValidationError: id is not a valid UUID`|`BadRequestError`|Check the notification ID|
|`403`|`AuthError: Error: Your system clock must be accurate to within 30 seconds`|`AuthError`|Check your system clock|
|`403`|`AuthError: Invalid token: API key not found`|`AuthError`|Use the correct API key. Refer to [API keys](#api-keys) for more information|
|`404`|`NoResultFound: No Result Found`|`NotFoundError`|Check your [template ID](#get-a-template-by-id-and-version-arguments-id-required) and [version](#version-required)|

### Get all templates

#### Method

This returns the latest version of all templates inside a collection object.

```ruby
args = {
  type: 'sms'
}
response = client.get_all_templates(args)
```

#### Arguments

##### type (optional)

If you do not use `type`, the client returns all templates. Otherwise you can filter by:

- `email`
- `sms`
- `letter`

#### Response

If the request to the client is successful, the client returns a `Notifications::Client::TemplateCollection` object. In the example shown in the [Method section](#get-all-templates-method), the object is named `response`.

You must then call the `.collection` method on this object to return an array of the required templates.

Once the client has returned a template array, you must then call the following methods on the templates in this array to return information on those templates.

|Method|Information|Type|
|:---|:---|:---|
|#`response.id`|Template UUID|String|
|#`response.name`|Template name|String|
|#`response.type`|Template type (email/sms/letter)|String|
|#`response.created_at`|Date and time template created|String|
|#`response.updated_at`|Date and time template last updated (may be nil if it is the first version)|String|
|#`response.created_by`|Email address of person that created the template|String|
|#`response.version`|Template version|String|
|#`response.body`|Template content|String|
|#`response.subject`|Template subject (email and letter)|String|
|#`response.letter_contact_block`|Template letter contact block (letter)|String|

If no templates exist for a template type or there no templates for a service, the templates array will be empty.

#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:---|:---|:---|:---|
|`400`|`ValidationError: Template type is not one of [sms, email, letter]`|`BadRequestError`|Contact the Notify team|

### Generate a preview template

#### Method

This generates a preview version of a template.

```ruby
response = client.generate_template_preview(id)
```

The parameters in the personalisation argument must match the placeholder fields in the actual template. The API notification client ignores any extra fields in the method.

#### Arguments

##### id (required)

The ID of the template. [Sign in to GOV.UK Notify](https://www.notifications.service.gov.uk/sign-in) and go to the __Templates__ page to find it. For example:

```ruby
'f33517ff-2a88-4f6e-b855-c550268ce08a'
```

##### personalisation (optional)

If a template has placeholder fields for personalised information such as name or application date, you must provide their values in a hash. For example:

```ruby
personalisation: {
  name: "John Smith",
  ID: "300241",
}
```

You can leave out this argument if a template does not have any placeholder fields for personalised information.

#### Response

If the request to the client is successful, the client returns a `Notifications::Client::TemplatePreview` object. In the example shown in the [Method section](#generate-a-preview-template-method), the object is named `response`.

You can then call different methods on this object to return the requested information.

|Method|Information|Type|
|:---|:---|:---|
|#`response.id`|Template UUID|String|
|#`response.version`|Template version|String|
|#`response.body`|Template content|String|
|#`response.subject`|Template subject (email and letter)|String|
|#`response.type`|Template type (sms/email/letter)|String|
|#`response.html`|Body as rendered HTML (email only)|String|

#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:---|:---|:---|:---|
|`400`|`BadRequestError: Missing personalisation: [PERSONALISATION FIELD]`|`BadRequestError`|Check that the personalisation arguments in the method match the placeholder fields in the template|
|`400`|`NoResultFound: No result found`|`BadRequestError`|Check the [template ID](#generate-a-preview-template-arguments-id-required)|
|`403`|`AuthError: Error: Your system clock must be accurate to within 30 seconds`|`AuthError`|Check your system clock|
|`403`|`AuthError: Invalid token: API key not found`|`AuthError`|Use the correct API key. Refer to [API keys](#api-keys) for more information|

## Get received text messages

This API call returns one page of up to 250 received text messages. You can get either the most recent messages, or get older messages by specifying a particular notification ID in the `older_than` argument.

You can only get the status of messages that are 7 days old or newer.

You can also set up [callbacks](#callbacks) for received text messages.

### Enable received text messages

Contact the GOV.UK Notify team using the [support page](https://www.notifications.service.gov.uk/support) or [chat to us on Slack](https://ukgovernmentdigital.slack.com/messages/C0E1ADVPC) to request a unique number for text message replies.

### Get a page of received text messages

#### Method

```ruby
args = {
  older_than: 'e194efd1-c34d-49c9-9915-e4267e01e92e'
}
response = client.get_received_texts(args)
```

To get older messages, pass the ID of an older notification into the `older_than` argument. This returns the next oldest messages from the specified notification ID.

If you leave out the `older_than` argument, the client returns the most recent 250 notifications.

#### Arguments

##### older_than (optional)

Input the ID of a received text message into this argument. If you use this argument, the client returns the next 250 received text messages older than the given ID. For example:

```ruby
older_than: '8e222534-7f05-4972-86e3-17c5d9f894e2'
```

If you leave out the `older_than` argument, the client returns the most recent 250 notifications.

The client only returns notifications that are 7 days old or newer. If the notification specified in this argument is older than 7 days, the client returns an empty `collection` response.

#### Response

If the request to the client is successful, the client returns a `Notifications::Client::ReceivedTextCollection` object. In the example shown in the [Method section](#get-a-page-of-received-text-messages-method), the object is named `response`.

You must then call either the `.links` method or the `.collection` method on this object.

|Method|Information|
|:---|:---|
|#`response.links`|Returns a hash linking to the requested texts (limited to 250)|
|#`response.collection`|Returns an array of the required texts|

If you call the `collection` method on this object to return an array, you must then call the following methods on the received texts in this array to return information on those texts:

|Method|Information|Type|
|:---|:---|:---|
|#`response.id`|Received text UUID|String|
|#`response.created_at`|Date and time of received text|String|
|#`response.content`|Received text content|String|
|#`response.notify_number`|Number that received text was sent to|String|
|#`response.service_id`|Received text service ID|String|
|#`response.user_number`|Number that received text was sent from|String|

If the notification specified in the `older_than` argument is older than 7 days, the client returns an empty `collection` response.

#### Error codes

If the request is not successful, the client raises a `Notifications::Client::RequestError` exception (or a subclass), which contains a code:

|error.code|error.message|class|How to fix|
|:---|:---|:---|:---|
|`403`|`AuthError: Error: Your system clock must be accurate to within 30 seconds`|`AuthError`|Check your system clock|
|`403`|`AuthError: Invalid token: API key not found`|`AuthError`|Use the correct API key. Refer to [API keys](#api-keys) for more information|
