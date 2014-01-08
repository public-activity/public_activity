module PublicActivity
  module ORM
    module ActiveRecord
      # Module extending classes that serve as owners
      module Activist
        # Adds ActiveRecord associations to model to simplify fetching
        # so you can list activities performed by the owner.
        # It is completely optional. Any model can be an owner to an activity
        # even without being an explicit activist.
        #
        # == Usage:
        # In model:
        #
        #   class User < ActiveRecord::Base
        #     include PublicActivity::Model
        #     activist
        #   end
        #
        # In controller:
        #   User.first.activities
        #
        def activist
          has_many "#{PublicActivity.config.table_name}_as_owner".to_sym,
            :class_name => "::PublicActivity::Activity",
            :as => :owner
          has_many "#{PublicActivity.config.table_name}_as_recipient".to_sym,
            :class_name => "::PublicActivity::Activity",
            :as => :recipient
        end
      end
    end
  end
end
