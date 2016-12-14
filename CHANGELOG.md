##2.0.0

###Changed
* Using version 2 of the notification-api.
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
