ENV['PA_ORM'] ||= 'active_record'

source :rubygems


gem 'yard'

case ENV['PA_ORM']
when 'active_record'
  gem 'activerecord', '~> 3.0'

when 'mongoid'
  gem 'mongoid', '~> 3.0'
end

group :development, :test do
  gem 'turn', require: false
  gem 'mocha', '>= 0.12.1'
  gem 'simplecov', '>= 0.6.4'
  gem 'sqlite3'
  gem 'minitest', '>= 4.3.0'
end

gemspec