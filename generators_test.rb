#!/usr/bin/env ruby
require 'rails/generators/test_case'
$:.unshift './lib'
require 'generators/public_activity/activity/activity_generator'
require 'test/unit'

class TestActivityGenerator < Rails::Generators::TestCase
  tests PublicActivity::Generators::ActivityGenerator
  destination File.expand_path("../tmp", File.dirname(__FILE__))
  setup :prepare_destination

  def test_generating_activity_model
    run_generator %w(activity)
    assert_file "app/models/activity.rb"
  end
end
