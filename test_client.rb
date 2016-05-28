require "./notify-ruby-client"

service = 'a74a6115-583b-4154-a86f-068ed30acc3e'
api_key = '6d554df6-03e3-4f0c-b70e-9f468c1e836a'
client = RubyClient.new("https://staging-api.notifications.service.gov.uk", service, api_key)


puts client.send_email("daz.ahern@digital.cabinet-office.gov.uk", "60cc6c57-5424-4fbf-89ac-3a7f0475b774")
