source "https://rubygems.org"
gemspec path: '..'

gem 'actionpack', '~> 3.0'
gem 'railties', '~> 3.0'
if ENV['PA_ORM'] == "active_record"
  gem 'activerecord', '~> 3.0.0'
end