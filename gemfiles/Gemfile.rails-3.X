source "https://rubygems.org"
gemspec path: '..'

gem 'actionpack', '~> 3.2'
gem 'railties', '~> 3.2'
if ENV['PA_ORM'] == "active_record"
  gem 'activerecord', '~> 3.2'
end