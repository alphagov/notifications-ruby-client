$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'notifications/client'
require 'webmock/rspec'
require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.find_definitions
  end
end
