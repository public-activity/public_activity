require 'generators/keep_track'
require 'rails/generators/active_record'

module KeepTrack
  module Generators
    class MigrationGenerator < ActiveRecord::Generators::Base
      extend Base

      argument :name, :type => :string, :default => 'create_activities'

      def generate_files
        migration_template 'migration.rb', "db/migrate/#{name}"
      end
    end
  end
end
