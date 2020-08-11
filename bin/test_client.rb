#!/usr/bin/env ruby
require './lib/notifications/client'

def main
  client = Notifications::Client.new(ENV['API_KEY'], ENV['NOTIFY_API_URL'])
  test_get_email_template_by_id(client, ENV['EMAIL_TEMPLATE_ID'])
  test_get_sms_template_by_id(client, ENV['SMS_TEMPLATE_ID'])
  test_get_letter_template_by_id(client, ENV['LETTER_TEMPLATE_ID'])
  test_get_template_version(client, ENV['SMS_TEMPLATE_ID'], 1)
  test_get_all_templates(client)
  test_get_all_templates_filter_by_type(client)
  test_generate_template_preview(client, ENV['EMAIL_TEMPLATE_ID'])
  email_notification = test_send_email_endpoint(client)
  email_notification_with_document = test_send_email_endpoint_with_document(client)
  sms_notification = test_send_sms_endpoint(client)
  letter_notification = test_send_letter_endpoint(client)
  precompiled_letter_notification = test_send_precompiled_letter_endpoint(client)
  test_get_notification_by_id_endpoint(client, email_notification.id, 'email')
  test_get_notification_by_id_endpoint(client, email_notification_with_document.id, 'email')
  test_get_notification_by_id_endpoint(client, sms_notification.id, 'sms')
  test_get_notification_by_id_endpoint(client, letter_notification.id, 'letter')
  test_get_notification_by_id_endpoint(client, precompiled_letter_notification.id, 'precompiled_letter')
  test_get_all_notifications(client)
  test_get_received_texts
  test_get_pdf_for_letter(client, letter_notification.id)
  p 'ruby client integration tests pass'
  exit 0
end

def test_get_email_template_by_id(client, id)
  response = client.get_template_by_id(id)
  test_template_response(response, 'email', 'test_get_email_template_by_id')
end

def test_get_sms_template_by_id(client, id)
  response = client.get_template_by_id(id)
  test_template_response(response, 'sms', 'test_get_sms_template_by_id')
end

def test_get_letter_template_by_id(client, id)
  response = client.get_template_by_id(id)
  test_template_response(response, 'letter', 'test_get_letter_template_by_id')
end

def test_get_template_version(client, id, version)
  response = client.get_template_version(id, version)
  test_template_response(response, 'sms', 'test_get_template_version')
end

def test_get_all_templates(client)
  response = client.get_all_templates
  unless response.is_a?(Notifications::Client::TemplateCollection)
    p 'failed test_get_all_templates response is not a Notifications::Client::TemplateCollection'
    exit 1
  end
  unless response.collection.length >= 3
    p 'failed test_get_all_templates, expected at least 3 templates returned.'
    exit 1
  end
  test_template_response(response.collection[0], 'letter', 'test_get_all_templates')
  test_template_response(response.collection[1], 'email', 'test_get_all_templates')
  test_template_response(response.collection[2], 'sms', 'test_get_all_templates')
end

def test_get_all_templates_filter_by_type(client)
  response = client.get_all_templates('type' => 'sms')
  unless response.is_a?(Notifications::Client::TemplateCollection)
    p 'failed test_get_all_templates response is not a Notifications::Client::TemplateCollection'
    exit 1
  end
  unless response.collection.length >= 1
    p 'failed test_get_all_templates, expected at least 2 templates returned.'
    exit 1
  end
  test_template_response(response.collection[0], 'sms', 'test_get_all_templates')
end

def test_generate_template_preview(client, id)
  response = client.generate_template_preview(id, personalisation: { "name" => "some name" })
  test_template_preview(response)
end

def test_template_response(response, template_type, test_method)
  unless response.is_a?(Notifications::Client::Template)
    p 'failed test_get_template_by_id response is not a Notifications::Client::Template'
    exit 1
  end
  unless response.id.is_a?(String)
    p 'failed template id is not a String'
    exit 1
  end

  field_should_not_be_nil(
    expected_fields_in_template_response(template_type),
    response,
    test_method
  )
  field_should_be_nil(
    expected_nil_fields_in_template_response(template_type),
    response,
    test_method
  )
end

def test_template_preview(response)
  unless response.is_a?(Notifications::Client::TemplatePreview)
    p 'failed test_generate_template_preview response is not a Notifications::Client::TemplatePreview'
    exit 1
  end
  unless response.id.is_a?(String)
    p 'failed template id is not a String'
    exit 1
  end
  field_should_not_be_nil(expected_fields_in_template_preview, response, 'generate_template_preview')
end

def test_send_email_endpoint(client)
  email_resp = client.send_email(email_address: ENV['FUNCTIONAL_TEST_EMAIL'],
                                 template_id: ENV['EMAIL_TEMPLATE_ID'],
                                 personalisation: { "name" => "some name" },
                                 reference: "some reference",
                                 email_reply_to_id: ENV['EMAIL_REPLY_TO_ID'])
  test_notification_response_data_type(email_resp, 'email')
  email_resp
end

def test_send_email_endpoint_with_document(client)
  email_resp = File.open('spec/test_files/test_pdf.pdf', 'rb') do |f|
    client.send_email(email_address: ENV['FUNCTIONAL_TEST_EMAIL'],
      template_id: ENV['EMAIL_TEMPLATE_ID'],
      personalisation: { name: Notifications.prepare_upload(f) },
      reference: "some reference",
      email_reply_to_id: ENV['EMAIL_REPLY_TO_ID'])
  end

  test_notification_response_data_type(email_resp, 'email')
  email_resp
end

def test_send_sms_endpoint(client)
  sms_resp = client.send_sms(phone_number: ENV['FUNCTIONAL_TEST_NUMBER'], template_id: ENV['SMS_TEMPLATE_ID'],
                             personalisation: { "name" => "some name" },
                             reference: "some reference",
                             sms_sender_id: ENV['SMS_SENDER_ID'])
  test_notification_response_data_type(sms_resp, 'sms')
  sms_resp
end

def test_send_letter_endpoint(client)
  letter_resp = client.send_letter(
    template_id: ENV['LETTER_TEMPLATE_ID'],
    personalisation: {
      address_line_1: "Her Majesty The Queen",
      address_line_2: "Buckingham Palace",
      postcode: "SW1 1AA"
    },
    reference: "some reference"
  )
  test_notification_response_data_type(letter_resp, 'letter')
  letter_resp
end

def test_send_precompiled_letter_endpoint(client)
  precompiled_letter_resp = File.open('spec/test_files/test_pdf.pdf', 'rb') do |file|
    client.send_precompiled_letter("some reference", file, "first")
  end

  test_notification_response_data_type(precompiled_letter_resp, 'precompiled_letter')

  precompiled_letter_resp
end

def test_notification_response_data_type(notification, message_type)
  unless notification.is_a?(Notifications::Client::ResponseNotification) || (notification.is_a?(Notifications::Client::ResponsePrecompiledLetter) && message_type == "precompiled_letter")
    p 'failed ' + message_type + ' response is not a Notifications::Client::ResponseNotification'
    exit 1
  end
  unless notification.id.is_a?(String)
    p 'failed ' + message_type + 'id is not a String'
    exit 1
  end

  if message_type == 'precompiled_letter'
    field_should_not_be_nil(expected_fields_in_precompiled_letter_response, notification, 'send_precompiled_letter')
    if notification.postage != "first"
      p "Postage should be set to 'first' for precompiled letter sending test. Right now it is set to #{notification.postage}"
      exit 1
    end
    return
  end

  field_should_not_be_nil(expected_fields_in_notification_response, notification, 'send_' + message_type)
  hash_key_should_not_be_nil(expected_fields_in_template, notification.send('template'), 'send_' + message_type + '.template')

  if message_type == 'email'
    hash_key_should_not_be_nil(expected_fields_in_email_content, notification.send('content'), 'send_' + message_type + '.content')
  elsif message_type == 'sms'
    hash_key_should_not_be_nil(expected_fields_in_sms_content, notification.send('content'), 'send_' + message_type + '.content')
  elsif message_type == 'letter'
    hash_key_should_not_be_nil(expected_fields_in_letter_content, notification.send('content'), 'send_' + message_type + '.content')
  end
end

def test_get_notification_by_id_endpoint(client, id, message_type)
  get_notification_response = client.get_notification(id)

  unless get_notification_response.is_a?(Notifications::Client::Notification)
    p 'get notification is not a Notifications::Client::Notification for id ' + id
    exit 1
  end

  if message_type == 'email'
    field_should_not_be_nil(expected_fields_in_email_notification, get_notification_response, 'Notifications::Client::Notification for type email')
    field_should_be_nil(expected_fields_in_email_notification_that_are_nil, get_notification_response, 'Notifications::Client::Notification for type email')
    hash_key_should_not_be_nil(expected_fields_in_template, get_notification_response.send('template'), 'Notifications::Client::Notification.template for type email')
  elsif message_type == 'sms'
    field_should_not_be_nil(expected_fields_in_sms_notification, get_notification_response, 'Notifications::Client::Notification for type sms')
    field_should_be_nil(expected_fields_in_sms_notification_that_are_nil, get_notification_response, 'Notifications::Client::Notification for type sms')
    hash_key_should_not_be_nil(expected_fields_in_template, get_notification_response.send('template'), 'Notifications::Client::Notification.template for type sms')
  elsif message_type == 'letter'
    field_should_not_be_nil(expected_fields_in_letter_notification, get_notification_response, 'Notifications::Client::Notification for type letter')
    field_should_be_nil(expected_fields_in_letter_notification_that_are_nil, get_notification_response, 'Notifications::Client::Notification for type letter')
    hash_key_should_not_be_nil(expected_fields_in_template, get_notification_response.send('template'), 'Notifications::Client::Notification.template for type letter')
  elsif message_type == 'precompiled_letter'
    field_should_not_be_nil(expected_fields_in_precompiled_letter_notification, get_notification_response, 'Notifications::Client::Notification for type precompiled letter')
    field_should_be_nil(expected_fields_in_precompiled_letter_notification_that_are_nil, get_notification_response, 'Notifications::Client::Notification for type precompiled letter')
    hash_key_should_not_be_nil(expected_fields_in_template, get_notification_response.send('template'), 'Notifications::Client::Notification.template for type precompiled letter')
  end
end

def test_get_pdf_for_letter(client, id)
  response = nil

  # try 15 times with 3 secs sleep between each attempt, to get the PDF
  15.times do
    begin
      response = client.get_pdf_for_letter(id)
    rescue Notifications::Client::BadRequestError
      sleep(3)
    end

    if !response.nil?
      break
    end
  end

  unless !response.nil? && response.start_with?("%PDF-")
    p "get_pdf_for_letter response for " + id + " is not a PDF: " + response.to_s
    exit 1
  end
end

def hash_key_should_not_be_nil(fields, obj, method_name)
  fields.each do |field|
    if obj.has_value?(:"#{field}")
      p 'contract test failed because ' + field + ' should not be nil for ' + method_name + ' response'
      exit 1
    end
  end
end

def field_should_not_be_nil(fields, obj, method_name)
  fields.each do |field|
    if obj.send(:"#{field}") == nil
      p 'contract test failed because ' + field + ' should not be nil for ' + method_name + ' response'
      exit 1
    end
  end
end

def field_should_be_nil(fields, obj, method_name)
  fields.each do |field|
    if obj.send(:"#{field}") != nil
      p 'contract test failed because ' + field + ' should be nil for ' + method_name + ' response'
      exit 1
    end
  end
end

def expected_fields_in_template_response(template_type)
  {
    "email" => ["id", "name", "type", "created_at", "created_by", "version", "body", "subject"],
    "sms" => ["id", "name", "type", "created_at", "created_by", "version", "body"],
    "letter" => ["id", "name", "type", "created_at", "created_by", "version", "body", "subject",
                 "letter_contact_block"],
  }[template_type]
end

def expected_nil_fields_in_template_response(template_type)
  {
    "email" => ["letter_contact_block"],
    "sms" => ["subject", "letter_contact_block"],
    "letter" => [],
  }[template_type]
end

def expected_fields_in_template_preview
  %w(id
     body
     version
     type
     html)
end

def expected_fields_in_notification_response
  %w(id
     reference
     content
     template
     uri)
end

def expected_fields_in_precompiled_letter_response
  %w(id
     reference
     postage)
end

def expected_fields_in_email_content
  %w(from_email
     body
     subject)
end

def expected_fields_in_sms_content
  %w(body
    from_number)
end

def expected_fields_in_letter_content
  %w(
    body
    subject
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
     created_at)
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
     created_by_name
     postage)
end

def expected_fields_in_sms_notification
  %w(id
     phone_number
     type
     status
     template
     body
     created_at)
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
     subject
     created_by_name
     postage)
end

def expected_fields_in_letter_notification
  %w(
    id
    type
    status
    template
    body
    subject
    line_1
    line_2
    postcode
    created_at
    postage
  )
end

def expected_fields_in_letter_notification_that_are_nil
  %w(
    phone_number
    email_address
    line_3
    line_4
    line_5
    line_5
    line_6
    created_by_name
  )
end

def expected_fields_in_precompiled_letter_notification
  %w(
    body
    created_at
    id
    line_1
    reference
    status
    subject
    template
    type
    postage
  )
end

def expected_fields_in_precompiled_letter_notification_that_are_nil
  %w(
    completed_at
    created_by_name
    email_address
    line_2
    line_3
    line_4
    line_5
    line_6
    phone_number
    postcode
    sent_at
  )
end

def expected_fields_in_template
  %w(id
     version
     uri)
end

def expected_fields_in_received_text_response
  %w(id
     created_at
     content
     notify_number
     service_id
     user_number)
end

def test_get_all_notifications(client)
  notifications = client.get_notifications
  unless notifications.is_a?(Notifications::Client::NotificationsCollection)
    p 'get all notifications is not Notifications::Client::NotificationsCollection'
    exit 1
  end
  field_should_not_be_nil(expected_fields_for_get_all_notifications, notifications, 'get_notifications')
end

def test_get_received_texts
  client = Notifications::Client.new(ENV['INBOUND_SMS_QUERY_KEY'], ENV['NOTIFY_API_URL'])
  response = client.get_received_texts
  unless response.is_a?(Notifications::Client::ReceivedTextCollection)
    p 'failed test_get_received_texts response is not a Notifications::Client::ReceivedTextCollection'
    exit 1
  end
  unless response.collection.length >= 0
    p 'failed test_get_received_texts, expected at least 1 received text returned.'
    exit 1
  end
  test_received_text_response(response.collection[0], 'test_received_text_response')
  test_received_text_response(response.collection[1], 'test_received_text_response')
  test_received_text_response(response.collection[2], 'test_received_text_response')
end

def test_received_text_response(response, test_method)
  unless response.is_a?(Notifications::Client::ReceivedText)
    p 'failed test_get_received_texts response is not a Notifications::Client::ReceivedText'
    exit 1
  end
  unless response.id.is_a?(String)
    p 'failed received text id is not a String'
    exit 1
  end
  field_should_not_be_nil(expected_fields_in_received_text_response, response, test_method)
end

def expected_fields_for_get_all_notifications
  %W(links
     collection)
end

if __FILE__ == $PROGRAM_NAME
  main
end
