ENV['PA_ORM'] ||= 'active_record'

source :rubygems

gem 'yard', '~> 0.8'

case ENV['PA_ORM']
when 'active_record'
  gem 'activerecord', '~> 3.0'


when 'mongoid'
  gem 'mongoid', '~> 3.0'
end

group :development, :test do
  gem 'sqlite3', '~> 1.3.7' if ENV['PA_ORM'] == 'active_record'
  gem 'mocha', '~> 0.13.0', require: false
  gem 'simplecov', '~> 0.7.0'
  gem 'minitest', '>= 4.3.0'
end

gemspec
