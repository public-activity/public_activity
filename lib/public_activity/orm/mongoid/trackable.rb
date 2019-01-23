# frozen_string_literal: true

module PublicActivity
  module ORM
    module Mongoid
      module Trackable
        def self.extended(base)
          base.has_many :activities, :class_name => "::PublicActivity::Activity", :as => :trackable
        end
      end
    end
  end
end
