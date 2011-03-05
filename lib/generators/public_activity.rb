require 'rails/generators/named_base'

module PublicActivity
  module Generators
    module Base
      def source_root
        @_public_activity_source_root ||= File.expand_path(File.join('../public_activity', generator_name, 'templates'), __FILE__)
      end
    end
  end
end
