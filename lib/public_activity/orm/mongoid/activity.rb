# frozen_string_literal: true

require 'mongoid'

module PublicActivity
  module ORM
    module Mongoid
      # The ActiveRecord model containing
      # details about recorded activity.
      class Activity
        include ::Mongoid::Document
        include ::Mongoid::Timestamps
        include ::Mongoid::Attributes::Dynamic if ::Mongoid::VERSION.split('.')[0].to_i >= 4
        include Renderable

        if ::Mongoid::VERSION.split('.')[0].to_i >= 7
          opts = { polymorphic: true, optional: true }
        else
          opts = { polymorphic: true }
        end

        # Define polymorphic association to the parent
        belongs_to :trackable,  opts
        # Define ownership to a resource responsible for this activity
        belongs_to :owner,      opts
        # Define ownership to a resource targeted by this activity
        belongs_to :recipient,  opts

        field :key,         type: String
        field :parameters,  type: Hash
      end
    end
  end
end
