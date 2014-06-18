module PublicActivity
  module ORM
    module MongoMapper
      module Trackable
        def self.extended(base)
          base.many :activities, :class_name => PublicActivity.config.model_name, order: :created_at.asc, :as => :trackable
        end
      end
    end
  end
end
