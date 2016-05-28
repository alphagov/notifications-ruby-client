$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'notifications/client'
require 'webmock/rspec'
require 'factory_girl'

Dir[Dir.pwd + "/spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.find_definitions
  end
end
