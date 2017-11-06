$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'notifications/client'
require 'webmock/rspec'
require 'factory_bot'

Dir[Dir.pwd + "/spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
