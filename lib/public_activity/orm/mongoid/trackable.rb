module PublicActivity
  module ORM
    module Mongoid
      module Trackable
        def self.extended(base)
          base.has_many :activities, :class_name => PublicActivity.config.model_name, :as => :trackable
        end
      end
    end
  end
end
