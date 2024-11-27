#!/usr/bin/env ruby
require './lib/notifications/client'

def main
  client = Notifications::Client.new(ENV['FUNCTIONAL_TESTS_SERVICE_API_TEST_KEY'], ENV['FUNCTIONAL_TESTS_API_HOST'])
  test_get_email_template_by_id(client, ENV['FUNCTIONAL_TEST_EMAIL_TEMPLATE_ID'])
  test_get_sms_template_by_id(client, ENV['FUNCTIONAL_TEST_SMS_TEMPLATE_ID'])
  test_get_letter_template_by_id(client, ENV['FUNCTIONAL_TEST_LETTER_TEMPLATE_ID'])
  test_get_template_version(client, ENV['FUNCTIONAL_TEST_SMS_TEMPLATE_ID'], 1)
  test_get_all_templates(client)
  test_get_all_templates_filter_by_type(client)
  test_generate_template_preview(client, ENV['FUNCTIONAL_TEST_EMAIL_TEMPLATE_ID'])
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
    raise 'failed test_get_all_templates response is not a Notifications::Client::TemplateCollection'
  end
  unless response.collection.length >= 3
    raise 'failed test_get_all_templates, expected at least 3 templates returned.'
  end
  test_template_response(response.collection.find { |template| template.id == ENV['FUNCTIONAL_TEST_LETTER_TEMPLATE_ID'] }, 'letter', 'test_get_all_templates')
  test_template_response(response.collection.find { |template| template.id == ENV['FUNCTIONAL_TEST_EMAIL_TEMPLATE_ID'] }, 'email', 'test_get_all_templates')
  test_template_response(response.collection.find { |template| template.id == ENV['FUNCTIONAL_TEST_SMS_TEMPLATE_ID'] }, 'sms', 'test_get_all_templates')
end

def test_get_all_templates_filter_by_type(client)
  response = client.get_all_templates('type' => 'sms')
  unless response.is_a?(Notifications::Client::TemplateCollection)
    raise 'failed test_get_all_templates response is not a Notifications::Client::TemplateCollection'
  end
  unless response.collection.length >= 1
    raise 'failed test_get_all_templates, expected at least 2 templates returned.'
  end
  test_template_response(response.collection[0], 'sms', 'test_get_all_templates')
end

def test_generate_template_preview(client, id)
  response = client.generate_template_preview(id, personalisation: { "build_id" => "some build id" })
  test_template_preview(response)
end

def test_template_response(response, template_type, test_method)
  unless response.is_a?(Notifications::Client::Template)
    raise 'failed test_get_template_by_id response is not a Notifications::Client::Template'
  end
  unless response.id.is_a?(String)
    raise 'failed template id is not a String'
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
    raise 'failed test_generate_template_preview response is not a Notifications::Client::TemplatePreview'
  end
  unless response.id.is_a?(String)
    raise 'failed template id is not a String'
  end
  field_should_not_be_nil(expected_fields_in_template_preview, response, 'generate_template_preview')
end

def test_send_email_endpoint(client)
  email_resp = client.send_email(
    email_address: ENV['FUNCTIONAL_TEST_EMAIL'],
    template_id: ENV['FUNCTIONAL_TEST_EMAIL_TEMPLATE_ID'],
    personalisation: { "build_id" => "some build id" },
    reference: "some reference",
    email_reply_to_id: ENV['FUNCTIONAL_TESTS_SERVICE_EMAIL_REPLY_TO_ID'],
    one_click_unsubscribe_url: "https://www.clovercouncil.gov.uk/unsubscribe?email_address=faye@example.com"
  )
  test_notification_response_data_type(email_resp, 'email')
  email_resp
end

def test_send_email_endpoint_with_document(client)
  email_resp = File.open('spec/test_files/test_pdf.pdf', 'rb') do |f|
    client.send_email(email_address: ENV['FUNCTIONAL_TEST_EMAIL'],
      template_id: ENV['FUNCTIONAL_TEST_EMAIL_TEMPLATE_ID'],
      personalisation: { build_id: Notifications.prepare_upload(f) },
      reference: "some reference",
      email_reply_to_id: ENV['FUNCTIONAL_TESTS_SERVICE_EMAIL_REPLY_TO_ID'],
      one_click_unsubscribe_url: "https://www.clovercouncil.gov.uk/unsubscribe?email_address=faye@example.com")
  end

  test_notification_response_data_type(email_resp, 'email')
  email_resp
end

def test_send_sms_endpoint(client)
  sms_resp = client.send_sms(phone_number: ENV['TEST_NUMBER'], template_id: ENV['FUNCTIONAL_TEST_SMS_TEMPLATE_ID'],
                             personalisation: { "build_id" => "some build_id" },
                             reference: "some reference",
                             sms_sender_id: ENV['FUNCTIONAL_TESTS_SERVICE_SMS_SENDER_ID'])
  test_notification_response_data_type(sms_resp, 'sms')
  sms_resp
end

def test_send_letter_endpoint(client)
  letter_resp = client.send_letter(
    template_id: ENV['FUNCTIONAL_TEST_LETTER_TEMPLATE_ID'],
    personalisation: {
      address_line_1: "Her Majesty The Queen",
      address_line_2: "Buckingham Palace",
      postcode: "SW1 1AA",
      build_id: "bome build id",
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
    raise 'failed ' + message_type + ' response is not a Notifications::Client::ResponseNotification'
  end
  unless notification.id.is_a?(String)
    raise 'failed ' + message_type + 'id is not a String'
  end

  if message_type == 'precompiled_letter'
    field_should_not_be_nil(expected_fields_in_precompiled_letter_response, notification, 'send_precompiled_letter')
    if notification.postage != "first"
      raise "Postage should be set to 'first' for precompiled letter sending test. Right now it is set to #{notification.postage}"
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
  get_notification_response = nil
  24.times do
    get_notification_response = client.get_notification(id)
    break if get_notification_response&.is_cost_data_ready
    sleep 5
  end

  raise "cost data didn't become ready in time" unless get_notification_response&.is_cost_data_ready

  unless get_notification_response.is_a?(Notifications::Client::Notification)
    raise 'get notification is not a Notifications::Client::Notification for id ' + id
  end

  if message_type == 'email'
    field_should_not_be_nil(expected_fields_in_email_notification, get_notification_response, 'Notifications::Client::Notification for type email')
    field_should_be_nil(expected_fields_in_email_notification_that_are_nil, get_notification_response, 'Notifications::Client::Notification for type email')
    hash_key_should_not_be_nil(expected_fields_in_template, get_notification_response.send('template'), 'Notifications::Client::Notification.template for type email')
    hash_should_be_empty(get_notification_response.send('cost_details'), 'Notifications::Client::Notification.cost_details for type sms')

  elsif message_type == 'sms'
    field_should_not_be_nil(expected_fields_in_sms_notification, get_notification_response, 'Notifications::Client::Notification for type sms')
    field_should_be_nil(expected_fields_in_sms_notification_that_are_nil, get_notification_response, 'Notifications::Client::Notification for type sms')
    hash_key_should_not_be_nil(expected_fields_in_template, get_notification_response.send('template'), 'Notifications::Client::Notification.template for type sms')
    hash_key_should_not_be_nil(expected_cost_details_fields, get_notification_response.send('cost_details'), 'Notifications::Client::Notification.cost_details for type sms')

  elsif message_type == 'letter'
    field_should_not_be_nil(expected_fields_in_letter_notification, get_notification_response, 'Notifications::Client::Notification for type letter')
    field_should_be_nil(expected_fields_in_letter_notification_that_are_nil, get_notification_response, 'Notifications::Client::Notification for type letter')
    hash_key_should_not_be_nil(expected_fields_in_template, get_notification_response.send('template'), 'Notifications::Client::Notification.template for type letter')
    hash_key_should_not_be_nil(expected_cost_details_fields, get_notification_response.send('cost_details'), 'Notifications::Client::Notification.cost_details for type sms')

  elsif message_type == 'precompiled_letter'
    field_should_not_be_nil(expected_fields_in_precompiled_letter_notification, get_notification_response, 'Notifications::Client::Notification for type precompiled letter')
    field_should_be_nil(expected_fields_in_precompiled_letter_notification_that_are_nil, get_notification_response, 'Notifications::Client::Notification for type precompiled letter')
    hash_key_should_not_be_nil(expected_fields_in_template, get_notification_response.send('template'), 'Notifications::Client::Notification.template for type precompiled letter')
    hash_key_should_not_be_nil(expected_cost_details_fields, get_notification_response.send('cost_details'), 'Notifications::Client::Notification.cost_details for type sms')

  end
end

def test_get_pdf_for_letter(client, id)
  response = nil

  24.times do
    begin
      response = client.get_pdf_for_letter(id)
      break
    rescue Notifications::Client::BadRequestError
      sleep(5)
    end
  end

  raise "pdf didn't become ready in time" if response.nil?
  raise "get_pdf_for_letter response for #{id} is not a PDF: #{response}" unless response.start_with?('%PDF-')
end

def hash_key_should_not_be_nil(fields, obj, method_name)
  fields.each do |field|
    if obj.has_value?(:"#{field}")
      raise 'contract test failed because ' + field + ' should not be nil for ' + method_name + ' response'
    end
  end
end

def hash_should_be_empty(hash, method_name)
  if !hash.empty?
      raise "contract test failed because #{hash} should be empty for #{method_name} response"
  end
end

def field_should_not_be_nil(fields, obj, method_name)
  fields.each do |field|
    if obj.send(:"#{field}") == nil
      raise 'contract test failed because ' + field + ' should not be nil for ' + method_name + ' response'
    end
  end
end

def field_should_be_nil(fields, obj, method_name)
  fields.each do |field|
    if obj.send(:"#{field}") != nil
      raise 'contract test failed because ' + field + ' should be nil for ' + method_name + ' response'
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
     subject
     one_click_unsubscribe_url)
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
     created_at
     one_click_unsubscribe_url
     is_cost_data_ready
     cost_in_pounds
     cost_details
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
     created_at
     is_cost_data_ready
     cost_in_pounds
     cost_details)
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
     postage
     one_click_unsubscribe_url)
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
    is_cost_data_ready
    cost_in_pounds
    cost_details
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
    one_click_unsubscribe_url
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
    one_click_unsubscribe_url
  )
end

def expected_fields_in_template
  %w(id
     version
     uri)
end

def expected_cost_details_fields
  %w(billable_sms_fragments
     international_rate_multiplier
     sms_rate
     billable_sheets_of_paper
     postage)
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
    raise 'get all notifications is not Notifications::Client::NotificationsCollection'
  end
  field_should_not_be_nil(expected_fields_for_get_all_notifications, notifications, 'get_notifications')
end

def test_get_received_texts
  client = Notifications::Client.new(ENV['FUNCTIONAL_TESTS_SERVICE_API_TEST_KEY'], ENV['FUNCTIONAL_TESTS_API_HOST'])
  response = client.get_received_texts
  unless response.is_a?(Notifications::Client::ReceivedTextCollection)
    raise 'failed test_get_received_texts response is not a Notifications::Client::ReceivedTextCollection'
  end
  unless response.collection.length >= 0
    raise 'failed test_get_received_texts, expected at least 1 received text returned.'
  end
  test_received_text_response(response.collection[0], 'test_received_text_response')
  test_received_text_response(response.collection[1], 'test_received_text_response')
  test_received_text_response(response.collection[2], 'test_received_text_response')
end

def test_received_text_response(response, test_method)
  unless response.is_a?(Notifications::Client::ReceivedText)
    raise 'failed test_get_received_texts response is not a Notifications::Client::ReceivedText'
  end
  unless response.id.is_a?(String)
    raise 'failed received text id is not a String'
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
