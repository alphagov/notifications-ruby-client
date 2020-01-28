## 5.1.2

* Change filesize too big exception message to refer to files rather than documents.

## 5.1.1

* Exceptions now return the error message when calling `#to_s` on them. This will make services like Sentry correctly display the full error description.

## 5.1.0

* Added new `get_pdf_for_letter` method
  * accepts a notification id argument
  * returns a string containing the final printable PDF for a precompiled or templated letter

## 5.0.0

* Dropped support for Ruby 2.3. Official support for this version ended in March (https://www.ruby-lang.org/en/news/2019/03/31/support-of-ruby-2-3-has-ended/)

## 4.0.0

* `RequestError.message` now returns a string, not an array of hashes – see https://github.com/alphagov/notifications-ruby-client/pull/72

## 3.1.0

* Added `html` field to the TemplatePreview response, so users can see
the rendered HTML of their email templates.

## 3.0.0

* Changed response class for `send_precompiled_letter` request from `ResponseNotification` to a new response class: `ResponsePrecompiledLetter`. This may affect users sending precompiled letters.
* Added an optional `postage` argument to `send_precompiled_letter` method, so users can specify postage when sending
a precompiled letter via API.
* Added postage to `Notification` class on the client.

## 2.10.0

* Added subclasses of the `RequestError` class to handle specific types of errors.

## 2.9.0

* Added the `send_precompiled_letter` method which allows the client to send letters as PDF files.
  * This requires two arguments - a reference for the letter and the PDF letter file. The file must conform to the Notify printing template.
* Added support for document uploads using the `send_email` method.

## 2.8.0

* Updated the Template class to have a `name` property, which is the name of the template as set in Notify.


## 2.7.0

* The Notification class has a new `created_by_name` property.
    * If the notification was sent manually this will be the name of the sender. If the notification was sent through the API this will be `nil`.

## 2.6.0

### Changed
* The client now validates that UUIDs derived from the API key are valid and raises a helpful error message if they are not.

## 2.5.0

### Changed
* Added a new `get_received_texts` method.
    * an optional `older_than` argument can be specified to retrieve the next 250 received text messages older than the given received text id. If omitted 250 of the most recent received text messages are returned.


## 2.4.0

### Changed
* It is now possible to have multiple SMS senders and to specify which sender an SMS notification should come from. Added the option to specify `sms_sender_id` when using the `send_sms` method. If no `sms_sender_id` is specified, the default sms sender will be used.
* Replaced `factory_girl` development dependency with `factory_bot`, which is the [new name for Factory girl.](https://robots.thoughtbot.com/factory_bot)


## 2.3.0

### Changed
* It is now possible to have multiple email to reply to addresses. Added the option to specify an `email_reply_to_id`
when using the `send_email` method. If no `email_reply_to_id` is specified, the default email reply to address will be
used.
* Upgraded all dependencies
* Minor code style changes and fixes for the tests

## 2.2.0

### Changed
* Added a new `send_letter` method
* Removed 'govuk-lint' gem as a development dependency


## 2.1.0

### Changed
* Added methods to get templates and generate a preview of a template.
* `get_template_by_id` - get the latest version of a template by id.
* `get_template_version` - get the template by id and version.
* `get_all_templates` - get all templates, can be filtered by template type.
* `generate_template_preview` - get the contents of a template with the placeholders replaced with the given personalisation.
* See the README for more information about the new template methods.


## 2.0.0

### Changed
* Using version 2 of the notification-api.
* A new `Notifications::Client` no longer requires the `service_id`, only the `api_key` is required.
* `Notifications::Client.send_sms()` input parameters and the response object has changed, see the README for more information.
 ```ruby
    client.sendSms(phone_number, template_id, personalisation, reference)
  ```
* `Notifications::Client.send_email()`  input parameters has changed and the response object, see the README for more information.
   ```ruby
      client.sendSms(phone_number, template_id, personalisation, reference)
    ```
* `reference` is a new optional argument of the send methods. The `reference` can be used as a unique reference for the notification. Because Notify does not require this reference to be unique you could also use this reference to identify a batch or group of notifications.
* `Notifications::Client.get_all_notifications()` => the response object has changed.
  * You can also filter the collection of `Notifications` by `reference`. See the README for more information.
* `Notifications::Client.get_notification(id)` => the response object has changed. See the README for more information.
* Initializing a client only requires the api key.
