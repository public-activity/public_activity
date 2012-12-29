module PublicActivity
  module ORM
    module ActiveRecord
      module Adapter
        class << self
          # Creates the activity on `trackable` with `options`
          def create_activity(trackable, options)
            trackable.activities.create(
              :key        => options[:key],
              :owner      => options[:owner],
              :recipient  => options[:recipient],
              :parameters => options[:params]
            )
          end
        end
      end
    end
  end
end
