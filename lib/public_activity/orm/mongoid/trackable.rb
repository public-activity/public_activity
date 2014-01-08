module PublicActivity
  module ORM
    module Mongoid
      module Trackable
        def self.extended(base)
          base.has_many PublicActivity.config.table_name.to_sym, :class_name => "::PublicActivity::Activity", :as => :trackable
        end
      end
    end
  end
end
