# frozen_string_literal: true

module PublicActivity
  module ORM
    module Mongoid
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
          has_many :activities_as_owner,
            :class_name => "::PublicActivity::Activity",
            :inverse_of => :owner

          has_many :activities_as_recipient,
            :class_name => "::PublicActivity::Activity",
            :inverse_of => :recipient
        end
      end
    end
  end
end
