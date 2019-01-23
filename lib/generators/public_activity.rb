# frozen_string_literal: true

require 'rails/generators/named_base'

module PublicActivity
  # A generator module with Activity table schema.
  module Generators
    # A base module
    module Base
      # Get path for migration template
      def source_root
        @_public_activity_source_root ||= File.expand_path(File.join('../public_activity', generator_name, 'templates'), __FILE__)
      end
    end
  end
end
