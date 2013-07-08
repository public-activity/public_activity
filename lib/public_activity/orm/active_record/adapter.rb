module PublicActivity
  module ORM
    module ActiveRecord
      # Provides ActiveRecord specific, database-related routines for use by
      # PublicActivity.
      class Adapter
        # Creates the activity on `trackable` with `options`
        def self.create_activity(trackable, options)
          trackable.activities.create options
        end
      end
    end
  end
end
