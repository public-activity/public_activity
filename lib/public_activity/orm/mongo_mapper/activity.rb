# frozen_string_literal: true

require 'mongo_mapper'
require 'active_support/core_ext'

module PublicActivity
  module ORM
    module MongoMapper
      # The MongoMapper document containing
      # details about recorded activity.
      class Activity
        include ::MongoMapper::Document
        include Renderable

        class SymbolHash < Hash
          def self.from_mongo(value)
            value.symbolize_keys unless value.nil?
          end
        end

        # Define polymorphic association to the parent
        belongs_to :trackable,  polymorphic: true
        # Define ownership to a resource responsible for this activity
        belongs_to :owner,      polymorphic: true
        # Define ownership to a resource targeted by this activity
        belongs_to :recipient,  polymorphic: true

        key :key,         String
        key :parameters,  SymbolHash

        timestamps!
      end
    end
  end
end
