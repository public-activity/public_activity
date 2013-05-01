module PublicActivity
  module ORM
    module Mongoid
      # Module extending classes that serve as owners
      module Activist
        extend ActiveSupport::Concern

        def self.extended(base)
          base.extend(ClassMethods)
        end
        # Association of activities as their owner.
        # @!method activities
        # @return [Array<Activity>] Activities which self is the owner of.

        # Association of activities as their recipient.
        # @!method private_activities
        # @return [Array<Activity>] Activities which self is the recipient of.

        # Module extending classes that serve as owners
        module ClassMethods
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
            has_many :activities_as_owner,      :class_name => "::PublicActivity::Activity", :inverse_of => :owner
            has_many :activities_as_recipient,  :class_name => "::PublicActivity::Activity", :inverse_of => :recipient
          end
        end
      end
    end
  end
end
