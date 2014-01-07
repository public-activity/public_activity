require 'generators/public_activity'
require 'rails/generators/active_record'

module PublicActivity
  module Generators
    # Migration generator that creates migration file from template
    class MigrationGenerator < ActiveRecord::Generators::Base
      extend Base

      argument :name, :type => :string, :default => "create_#{PublicActivity.config.table_name}"
      # Create migration in project's folder
      def generate_files
        migration_template 'migration.rb', "db/migrate/#{name}"
      end
    end
  end
end
