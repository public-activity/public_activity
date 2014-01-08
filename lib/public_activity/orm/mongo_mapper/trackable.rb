module PublicActivity
  module ORM
    module MongoMapper
      module Trackable
        def self.extended(base)
          base.many PublicActivity.config.table_name.to_sym, :class_name => "::PublicActivity::Activity", order: :created_at.asc, :as => :trackable
        end
      end
    end
  end
end
