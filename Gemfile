source "https://rubygems.org"

group :development, :test do
  gem 'sqlite3', '~> 1.3.7' if ENV['PA_ORM'] == 'active_record'
  gem 'mocha', '~> 0.13.0', require: false
  gem 'simplecov', '~> 0.7.0'
  gem 'minitest', '>= 4.3.0'
  gem 'redcarpet'
  gem 'yard', '~> 0.8'
  gem 'mongoid', git: 'git://github.com/mongoid/mongoid.git' #'~> 3.1.3'
  gem 'activerecord', '>= 3.0.0.rc' #'>= 3.2.0'
end

gemspec
