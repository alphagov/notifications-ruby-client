require "net/https"
require "uri"
require "jwt"
require "time"
require "json"
require "rspec"


class RubyClient
	def initialize (baseURL, service_id, secret)
		@baseURL = baseURL
		@service_id = service_id
		@secret = secret
	end

	def create_api_token
		exp = Time.now.to_i + 4 * 3600
		exp_payload =  {:iss => @service_id, :iat => Time.now.to_i}
		token = JWT.encode exp_payload, @secret, 'HS256'
		return token
	end


	def send_email(to, template, personalisation=nil)

	uri = URI.parse(@baseURL + "/notifications/email")
	headers = {
           "Content-type" => "application/json",
           "Authorization" => "Bearer " + create_api_token,
           "User-agent" => "NOTIFY-API-RUBY-CLIENT"
      		 }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri, headers)

	if !personalisation.nil?
		then
		request.set_form_data
	({

		to: => to,
  		template: => template,
  		personalisation: => personalisation
	})
	else
		request.set_form_data
	({

		to: => to,
  		template: => template
	})
	end


	response = http.request(request, headers)

	puts response.code
	puts response.body


	end

end
