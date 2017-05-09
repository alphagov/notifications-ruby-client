#!/usr/bin/env ruby
require 'notifications/client'
require 'notifications/client/notification'
require 'notifications/client/response_notification'
require 'notifications/client/notification'
require 'notifications/client/response_template'
require 'notifications/client/template_collection'

def main
  client = Notifications::Client.new(ENV['API_KEY'], ENV['NOTIFY_API_URL'])
  test_get_template_by_id(client, ENV['EMAIL_TEMPLATE_ID'])
  test_get_template_version(client, ENV['SMS_TEMPLATE_ID'], 1)
  test_get_all_templates(client)
  test_get_all_templates_filter_by_type(client)
  test_generate_template_preview(client, ENV['EMAIL_TEMPLATE_ID'])
  email_notification = test_send_email_endpoint(client)
  sms_notification = test_send_sms_endpoint(client)
  test_get_notification_by_id_endpoint(client, email_notification.id, 'email')
  test_get_notification_by_id_endpoint(client, sms_notification.id, 'sms')
  test_get_all_notifications(client)
  p 'ruby client integration tests pass'
  exit 0
end

def test_get_template_by_id(client, id)
  response = client.get_template_by_id(id)
  test_template_response(response, 'test_get_template_by_id')
end

def test_get_template_version(client, id, version)
  response = client.get_template_version(id, version)
  test_template_response(response, 'test_get_template_version')
end

def test_get_all_templates(client)
  response = client.get_all_templates()
  unless response.is_a?(Notifications::Client::TemplateCollection) then
    p 'failed test_get_all_templates response is not a Notifications::Client::TemplateCollection'
    exit 1
  end
  unless response.collection.length >= 2 then
    p 'failed test_get_all_templates, expected at least 2 templates returned.'
    exit 1
  end
  test_template_response(response.collection[0], 'test_get_all_templates')
  test_template_response(response.collection[1], 'test_get_all_templates')
end

def test_get_all_templates_filter_by_type(client)
  response = client.get_all_templates({'type' => 'sms'})
  unless response.is_a?(Notifications::Client::TemplateCollection) then
    p 'failed test_get_all_templates response is not a Notifications::Client::TemplateCollection'
    exit 1
  end
  unless response.collection.length >= 1 then
    p 'failed test_get_all_templates, expected at least 2 templates returned.'
    exit 1
  end
  test_template_response(response.collection[0], 'test_get_all_templates')
end

def test_generate_template_preview(client, id)

  response = client.generate_template_preview(id, personalisation:Hash["name", "some name"])
  test_template_preview(response)
end

def test_template_response(response, test_method)
  unless response.is_a?(Notifications::Client::Template) then
    p 'failed test_get_template_by_id response is not a Notifications::Client::Template'
    exit 1
  end
  unless response.id.is_a?(String) then
    p 'failed template id is not a String'
    exit 1
  end
  field_should_not_be_nil(expected_fields_in_template_response, response, test_method)
end

def test_template_preview(response)
  unless response.is_a?(Notifications::Client::TemplatePreview) then
    p 'failed test_generate_template_preview response is not a Notifications::Client::TemplatePreview'
    exit 1
  end
  unless response.id.is_a?(String) then
    p 'failed template id is not a String'
    exit 1
  end
  field_should_not_be_nil(expected_fields_in_template_preview, response, 'generate_template_preview')
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
  field_should_not_be_nil(expected_fields_in_notification_response, notification, 'send_'+message_type)
  hash_key_should_not_be_nil(expected_fields_in_template, notification.send('template'), 'send_'+message_type+'.template')
  if message_type == 'email' then
    hash_key_should_not_be_nil(expected_fields_in_email_content, notification.send('content'), 'send_'+message_type+'.content')
  end
  if message_type == 'sms' then
    hash_key_should_not_be_nil(expected_fields_in_sms_content, notification.send('content'),'send_'+message_type+'.content')
  end

end

def test_get_notification_by_id_endpoint(client, id, message_type)
  get_notification_response = client.get_notification(id)

  unless get_notification_response.is_a?(Notifications::Client::Notification) then
    p 'get notification is not a Notifications::Client::Notification for id ' + id
    exit 1
  end
  if message_type == 'email' then
    field_should_not_be_nil(expected_fields_in_email_notification, get_notification_response, 'Notifications::Client::Notification for type email')
    field_should_be_nil(expected_fields_in_email_notification_that_are_nil, get_notification_response, 'Notifications::Client::Notification for type email')
    hash_key_should_not_be_nil(expected_fields_in_template, get_notification_response.send('template'), 'Notifications::Client::Notification.template for type email')
  end
  if message_type == 'sms' then
    field_should_not_be_nil(expected_fields_in_sms_notification, get_notification_response, 'Notifications::Client::Notification for type sms')
    field_should_be_nil(expected_fields_in_sms_notification_that_are_nil, get_notification_response, 'Notifications::Client::Notification for type sms')
    hash_key_should_not_be_nil(expected_fields_in_template, get_notification_response.send('template'), 'Notifications::Client::Notification.template for type sms')
  end

end


def hash_key_should_not_be_nil(fields, obj, method_name)
  fields.each do |field|
    if obj.has_value?(:"#{field}") then
      p 'contract test failed because ' + field + ' should not be nil for ' + method_name + ' response'
      exit 1
    end
  end
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

def expected_fields_in_template_response
  %w(id
     type
     created_at
     created_by
     body
     version
)
end

def expected_fields_in_template_preview
  %w(id
     body
     version
     type
)
end

def expected_fields_in_notification_response
  %w(id
     reference
     content
     template
     uri
)
end

def expected_fields_in_email_content
  %w(from_email
     body
     subject
)
end

def expected_fields_in_sms_content
  %w(body
     )
end

def expected_fields_in_email_notification
  %w(id
     email_address
     type
     status
     template
     body
     subject
     created_at
)
end

def expected_fields_in_email_notification_that_are_nil
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

def expected_fields_in_sms_notification
  %w(id
     phone_number
     type
     status
     template
     body
     created_at
   )
end

def expected_fields_in_sms_notification_that_are_nil
  %w(email_address
     line_1
     line_2
     line_3
     line_4
     line_5
     line_5
     line_6
     postcode
     subject)
end

def expected_fields_in_template
  %w(id
     version
     uri)
end

def test_get_all_notifications(client)
  notifications = client.get_notifications()
  unless notifications.is_a?(Notifications::Client::NotificationsCollection) then
    p 'get all notifications is not Notifications::Client::NotificationsCollection'
    exit 1
  end
  field_should_not_be_nil(expected_fields_for_get_all_notifications, notifications, 'get_notifications')
end

def expected_fields_for_get_all_notifications
  %W(links
	collection
	)
end

if __FILE__ == $PROGRAM_NAME
  main
end
