Bundler.setup(:default, :test)
require File.expand_path('lib/keep_track.rb')

Dir[File.expand_path('support/*')].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
end

