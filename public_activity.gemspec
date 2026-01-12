# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'public_activity/version'

Gem::Specification.new do |s|
  s.name = 'public_activity'
  s.version = PublicActivity::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Juri Hahn', 'Piotrek Okoński', 'Kuba Okoński']
  s.email = 'juri.hahn+public-activity@gmail.com'
  s.homepage = 'https://github.com/public-activity/public_activity'
  s.summary = 'Easy activity tracking for ActiveRecord models'
  s.description = 'Easy activity tracking for your ActiveRecord models. Provides Activity model with details about actions performed by your users, like adding comments, responding etc.'
  s.license = 'MIT'
  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/public-activity/public_activity/issues",
    'changelog_uri'     => 'https://github.com/public-activity/public_activity/blob/main/CHANGELOG.md',
    "documentation_uri" => "https://rubydoc.info/gems/public_activity",
    "homepage_uri"      => s.homepage,
    "source_code_uri"   => "https://github.com/public-activity/public_activity",
    "rubygems_mfa_required" => "true",
  }

  s.files = `git ls-files lib`.split("\n") + %w[Gemfile Rakefile README.md MIT-LICENSE CHANGELOG.md]
  s.test_files = `git ls-files test`.split("\n")
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.2.0'

  s.post_install_message = File.read('UPGRADING') if File.exist?('UPGRADING')

  s.add_dependency 'actionpack', '>= 7.2'
  s.add_dependency 'i18n', '>= 0.5.0'
  s.add_dependency 'railties', '>= 7.2'

  ENV['PA_ORM'] ||= 'active_record'
  case ENV['PA_ORM']
  when 'active_record'
    s.add_dependency 'activerecord', '>= 7.2'
  when 'mongoid'
    s.add_dependency 'mongoid',      '>= 4.0'
  when 'mongo_mapper'
    s.add_dependency 'bson_ext'
    s.add_dependency 'mongo', '<= 1.9.2'
    s.add_dependency 'mongo_mapper', '>= 0.12.0'
  end

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3', '~> 2.1'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rake'
end
