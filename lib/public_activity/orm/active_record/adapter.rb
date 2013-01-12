module PublicActivity
  module ORM
    module ActiveRecord
      module Adapter
        class << self
          # Creates the activity on `trackable` with `options`
          def create_activity(trackable, options)
            trackable.activities.create options
          end
        end
      end
    end
  end
end
