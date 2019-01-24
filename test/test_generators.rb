# frozen_string_literal: true

if ENV["PA_ORM"] == "active_record"

  require 'test_helper'
  require 'rails/generators/test_case'
  require 'generators/public_activity/activity/activity_generator'
  require 'generators/public_activity/migration/migration_generator'
  require 'generators/public_activity/migration_upgrade/migration_upgrade_generator'

  class TestActivityGenerator < Rails::Generators::TestCase
    tests PublicActivity::Generators::ActivityGenerator
    destination File.expand_path("../tmp", File.dirname(__FILE__))
    setup :prepare_destination

    def test_generating_activity_model
      run_generator
      assert_file "app/models/activity.rb"
    end
  end

  class TestMigrationGenerator < Rails::Generators::TestCase
    tests PublicActivity::Generators::MigrationGenerator
    destination File.expand_path("../tmp", File.dirname(__FILE__))
    setup :prepare_destination

    def test_generating_activity_model
      run_generator
      assert_migration "db/migrate/create_activities.rb"
    end
  end

  class TestMigrationUpgradeGenerator < Rails::Generators::TestCase
    tests PublicActivity::Generators::MigrationUpgradeGenerator
    destination File.expand_path("../tmp", File.dirname(__FILE__))
    setup :prepare_destination

    def test_generating_activity_model
      run_generator
      assert_migration "db/migrate/upgrade_activities.rb"
    end
  end
end
