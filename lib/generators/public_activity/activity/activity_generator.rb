require 'rails/generators/active_record'

module PublicActivity
  module Generators
    # Activity generator that creates activity model file from template
    class ActivityGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      argument :name, :type => :string, :default => 'activity'
      # Create model in project's folder
      def generate_files
        copy_file 'activity.rb', "app/models/#{name}.rb"
      end
    end
  end
end
