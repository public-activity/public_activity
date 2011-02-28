require 'rails/generators/named_base'

module KeepTrack
  module Generators
    module Base
      def source_root
        @_keep_track_source_root ||= File.expand_path(File.join('../keep_track', generator_name, 'templates'), __FILE__)
      end
    end
  end
end
