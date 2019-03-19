# frozen_string_literal: true

module PublicActivity
  module ORM
    module Mongoid
      class Adapter
        # Creates the activity on `trackable` with `options`
        def self.create_activity(trackable, options)
          trackable.activities.create options
        end

        # Creates activity on `trackable` with `options`; throws error on validation failure
        def self.create_activity!(trackable, options)
          trackable.activities.create! options
        end
      end
    end
  end
end
