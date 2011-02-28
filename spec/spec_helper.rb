require 'rspec'

Dir[File.expand_path('support/*')].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
end

