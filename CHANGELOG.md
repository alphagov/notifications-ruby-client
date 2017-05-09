##2.1.0

###Changed
* Added methods to get templates and generate a preview of a template.
* `get_template_by_id` - get the latest version of a template by id.
* `get_template_version` - get the template by id and version.
* `get_all_templates` - get all templates, can be filtered by template type.
* `generate_template_preview` - get the contents of a template with the placeholders replaced with the given personalisation.
* See the README for more information about the new template methods.


##2.0.0

###Changed
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
