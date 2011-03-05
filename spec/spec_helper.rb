Bundler.setup(:default, :test)
require File.expand_path('lib/public_activity.rb')

Dir[File.expand_path('support/*')].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
end

