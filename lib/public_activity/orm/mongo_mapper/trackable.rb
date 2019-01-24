# frozen_string_literal: true

module PublicActivity
  module ORM
    module MongoMapper
      module Trackable
        def self.extended(base)
          base.many :activities, :class_name => "::PublicActivity::Activity", order: :created_at.asc, :as => :trackable
        end
      end
    end
  end
end
