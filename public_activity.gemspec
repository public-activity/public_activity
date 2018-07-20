# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'public_activity/version'

Gem::Specification.new do |s|
  s.name = 'public_activity'
  s.version = PublicActivity::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Piotrek Okoński", "Kuba Okoński"]
  s.email = "piotrek@okonski.org"
  s.homepage = 'https://github.com/pokonski/public_activity'
  s.summary = "Easy activity tracking for ActiveRecord models"
  s.description = "Easy activity tracking for your ActiveRecord models. Provides Activity model with details about actions performed by your users, like adding comments, responding etc."
  s.license = "MIT"

  s.files = `git ls-files lib`.split("\n") + ['Gemfile','Rakefile','README.md', 'MIT-LICENSE']
  s.test_files = `git ls-files test`.split("\n")
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.2'

  if File.exist?('UPGRADING')
    s.post_install_message = File.read("UPGRADING")
  end

  s.add_dependency 'actionpack', '>= 3.0.0'
  s.add_dependency 'railties', '>= 3.0.0'
  s.add_dependency 'i18n', '>= 0.5.0'

  ENV['PA_ORM'] ||= 'active_record'
  case ENV['PA_ORM']
  when 'active_record'
    s.add_dependency 'activerecord', '>= 3.0'
  when 'mongoid'
    s.add_dependency 'mongoid',      '>= 4.0'
  when 'mongo_mapper'
    s.add_dependency 'bson_ext'
    s.add_dependency 'mongo_mapper', '>= 0.12.0'
    s.add_dependency 'mongo', '<= 1.9.2'
  end

  s.add_development_dependency 'sqlite3', '~> 1.3.7'
  s.add_development_dependency 'mocha', '~> 1.5.0'
  s.add_development_dependency 'simplecov', '~> 0.7.0'
  s.add_development_dependency 'test-unit', '~> 3.2.8'
  s.add_development_dependency 'minitest', '~> 4.7.5'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'yard', '~> 0.9.11'
  s.add_development_dependency 'pry'
end
