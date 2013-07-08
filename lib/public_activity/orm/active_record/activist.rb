module PublicActivity
  module ORM
    module ActiveRecord
      # Module extending classes that serve as owners
      module Activist
        extend ActiveSupport::Concern

        # Loads the {ClassMethods#activist} method for declaring the class
        # as an activist.
        def self.extended(base)
          base.extend(ClassMethods)
        end


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
            # Association of activities as their owner.
            # @!method activities_as_owner
            # @return [Array<Activity>] Activities which self is the owner of.
            has_many :activities_as_owner, :class_name => "::PublicActivity::Activity", :as => :owner

            # Association of activities as their recipient.
            # @!method activities_as_recipient
            # @return [Array<Activity>] Activities which self is the recipient of.
            has_many :activities_as_recipient, :class_name => "::PublicActivity::Activity", :as => :recipient
          end
        end
      end
    end
  end
end
