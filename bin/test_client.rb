#!/usr/bin/env ruby
require 'notifications/client'
require 'notifications/client/notification'
require 'notifications/client/response_notification'
require 'notifications/client/notification'

def main
  client = Notifications::Client.new(ENV['SERVICE_ID'], ENV['API_KEY'], ENV['NOTIFY_API_URL'])
  email_notification = test_send_email_endpoint(client)
  sms_notification = test_send_sms_endpoint(client)
  test_get_notification_by_id_endpoint(client, email_notification.id, 'email')
  test_get_notification_by_id_endpoint(client, sms_notification.id, 'sms')
  test_get_all_notifications(client, sms_notification.id, email_notification.id)
  p 'ruby client integration tests pass'
  exit 0
end

def test_send_email_endpoint(client)
  email_resp = client.send_email(email_address: ENV['FUNCTIONAL_TEST_EMAIL'], template_id: ENV['EMAIL_TEMPLATE_ID'],
                                 personalisation:Hash["name", "some name"],
                                 reference: "some reference")
  test_notification_response_data_type(email_resp, 'email')
  email_resp
end

def test_send_sms_endpoint(client)
  sms_resp = client.send_sms(phone_number: ENV['FUNCTIONAL_TEST_NUMBER'], template_id: ENV['SMS_TEMPLATE_ID'],
                             personalisation:Hash["name", "some name"],
                             reference: "some reference")
  test_notification_response_data_type(sms_resp, 'sms')
  sms_resp
end

def test_notification_response_data_type(notification, message_type)
  unless notification.is_a?(Notifications::Client::ResponseNotification) then
    p 'failed ' + message_type +' response is not a Notifications::Client::ResponseNotification'
    exit 1
  end
  unless notification.id.is_a?(String) then
    p 'failed '+ message_type + 'id is not a String'
    exit 1
  end
end

def test_get_notification_by_id_endpoint(client, id, message_type)
  get_notification_response = get_notification_for_id(client, id, message_type)
  unless get_notification_response.is_a?(Notifications::Client::Notification) then
    p 'get notification is not a Notifications::Client::Notification for id ' + id
    exit 1
  end
  if message_type == 'email' then
    field_should_not_be_nil(expected_fields_in_email_resp, get_notification_response, 'send_email')
    field_should_be_nil(expected_fields_in_email_resp_that_are_nil, get_notification_response, 'send_email')
  end
  if message_type == 'sms' then
    field_should_not_be_nil(expected_fields_in_sms_resp, get_notification_response, 'send_sms')
    field_should_be_nil(expected_fields_in_sms_resp_that_are_nil, get_notification_response, 'send_sms')
  end
end


def get_notification_for_id(client, id, message_type)
  max_attempts = 0
  wait_for_sent_message = true
  while max_attempts < 3 && wait_for_sent_message
    begin
      get_notification_response = client.get_notification(id)
      wait_for_sent_message = false
    rescue Notifications::Client::RequestError => no_result
      if no_result.message == "No result found"
        max_attempts = max_attempts + 1
        sleep 3
      else
        p 'get_notification threw an exception for the ' + message_type + ' notification'
        p no_result.to_s
        exit 1
      end
    end
    if get_notification_response != nil && get_notification_response.send(:'status') == 'created'
      # we want to test the sent response?
      wait_for_sent_message = true
    end
  end
  if max_attempts == 3 then
    p 'get_notification failed because the ' + message_type + ' notification was not found'
    exit 1
  end
  get_notification_response
end

def field_should_not_be_nil(fields, obj, method_name)
  fields.each do |field|
    if obj.send(:"#{field}") == nil then
      p 'contract test failed because ' + field + ' should not be nil for ' + method_name + ' response'
      exit 1
    end
  end
end

def field_should_be_nil(fields, obj, method_name)
  fields.each do |field|
    if obj.send(:"#{field}") != nil then
      p 'contract test failed because ' + field + ' should be nil for ' + method_name + ' response'
      exit 1
    end
  end
end

def expected_fields_in_email_resp
  %w(id
     reference
     email_address
     type
     status
     sent_at
     template
     created_at
)
end

def expected_fields_in_email_resp_that_are_nil
  %w(phone_number
     line_1
     line_2
     line_3
     line_4
     line_5
     line_5
     line_6
     postcode
     )
end

def expected_fields_in_sms_resp
  %w(id
     phone_number
     type
     status
     sent_at
     template
     created_at
   )
end

def expected_fields_in_sms_resp_that_are_nil
  %w(email_address
     line_1
     line_2
     line_3
     line_4
     line_5
     line_5
     line_6
     postcode)
end

def test_get_all_notifications(client, first_id, second_id)
  notifications = client.get_notifications()
  unless notifications.is_a?(Notifications::Client::NotificationsCollection) then
    p 'get all notifications is not Notifications::Client::NotificationsCollection'
    exit 1
  end

  field_should_not_be_nil(expected_fields_for_get_all_notifications, notifications, 'get_notifications')

  notification_collection = notifications.send(:'collection')
  unless notification_collection[0].id == first_id then
    p 'first item in notification_collection is not the expected notification, last message sent'
    exit 0
  end
  unless notification_collection[1].id == second_id then
    p 'second item in notification_collection is not the expected notification, second last message sent'
    exit 0
  end
end

def expected_fields_for_get_all_notifications
  %W(links
	collection
	)
end

if __FILE__ == $PROGRAM_NAME
  main
end
