module PublicActivity
  # Module extending classes that serve as owners
  module Activist
    extend ActiveSupport::Concern

    # Association of activities as their owner.
    # @!method activities
    # @return [Array<Activity>] Activities which self is the owner of.

    # Association of activities as their recipient.
    # @!method private_activities
    # @return [Array<Activity>] Activities which self is the recipient of.

    # Module extending classes that serve as owners
    module ClassMethods
      # Adds has_many :activities association to model
      # so you can list activities performed by the owner.
      # It is completely optional, but simplifies your work.
      #
      # == Usage:
      # In model:
      #
      #   class User < ActiveRecord::Base
      #     activist
      #   end
      #
      # In controller:
      #   User.first.activities
      #
      def activist
        has_many :activities, :class_name => "PublicActivity::Activity", :as => :owner
        has_many :private_activities, :class_name => "PublicActivity::Activity", :as => :recipient
      end
    end
  end
end
