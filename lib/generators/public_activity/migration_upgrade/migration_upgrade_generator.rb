# frozen_string_literal: true

require 'generators/public_activity'
require 'rails/generators/active_record'

module PublicActivity
  module Generators
    # Migration generator that creates migration file from template
    class MigrationUpgradeGenerator < ActiveRecord::Generators::Base
      extend Base

      argument :name, :type => :string, :default => 'upgrade_activities'
      # Create migration in project's folder
      def generate_files
        migration_template 'upgrade.rb', "db/migrate/#{name}.rb"
      end
    end
  end
end
