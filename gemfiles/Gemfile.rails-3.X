ENV['PA_ORM'] ||= 'active_record'
source "https://rubygems.org"
gemspec

gem 'actionpack', '~> 3.0'
gem 'railties', '~> 3.0'

group :development, :test do
  gem 'sqlite3', '~> 1.3.7'
  gem 'mocha', '~> 0.13.0', require: false
  gem 'simplecov', '~> 0.7.0'
  gem 'minitest', '< 5.0.0'
  gem 'redcarpet'
  gem 'yard', '~> 0.8'
  
  case ENV['PA_ORM']
  when 'active_record'
    gem 'activerecord', '~> 3.0'
  when 'mongoid'
    gem 'mongoid',      '~> 3.0'
  when 'mongo_mapper'
    gem 'bson_ext'
    gem 'mongo_mapper', '>= 0.12.0'
  end
end