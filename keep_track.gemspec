# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'keep_track/version'

Gem::Specification.new do |s|
  s.name = 'keep_track'
  s.version = KeepTrack::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Piotrek Okoński", "Kuba Okoński"]
  s.email = ["piotrek@okonski.org", "kuba@okonski.org"]
  s.homepage = 'https://github.com/okonski/keep_track'
  s.summary = "Smooth acitivity tracking for ActiveRecord models"
  s.description = "Smooth acitivity tracking for ActiveRecord models. Provides Activity model with details about actions performed by your users, like adding comments, responding etc."

  s.files = `git ls-files lib`.split("\n") + ['README', 'MIT-LICENSE']
  s.test_files = `git ls-files spec`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activerecord', '>= 3.0.0'
  s.add_dependency 'activesupport', '>= 3.0.0'
  s.add_dependency 'i18n', '>= 0.5.0'
  
  s.add_development_dependency 'rspec'
end
