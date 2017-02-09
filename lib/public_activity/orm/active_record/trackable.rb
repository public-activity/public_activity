module PublicActivity
  module ORM
    module ActiveRecord
      # Implements {PublicActivity::Trackable} for ActiveRecord
      # @see PublicActivity::Trackable
      module Trackable
        # Creates an association for activities where self is the *trackable*
        # object.
        def self.extended(base)
          base.has_many :activities, :class_name => PublicActivity.config.model_name, :as => :trackable
        end
      end
    end
  end
end
