ENV['PA_ORM'] ||= 'active_record'
source "https://rubygems.org"
gemspec path: '..'

gem 'actionpack', '~> 3.0'
gem 'railties', '~> 3.0'
gem 'activerecord', '~> 3.0'