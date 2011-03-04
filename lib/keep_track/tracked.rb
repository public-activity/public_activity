module KeepTrack
  # Add a flag to determine whether a model class is being tracked
  module Tracked
    extend ActiveSupport::Concern

    #Set attributes that will be passed to activity when saving
    attr_accessor :activity_params
    @activity_params = {}
    attr_accessor :activity_user
    @activity_user = nil
    attr_accessor :activity_key
    @activity_key = nil
    # Overrides the +tracked+ method to first define the +tracked?+ class method before
    # deferring to the original +tracked+.
    module ClassMethods
      def tracked(*args)
        super(*args)

        class << self
          def tracked?
            true
          end
        end
      end

      # For ActiveRecord::Base models that do not call the +tracked+ method, the +tracked?+
      # will return false
      def tracked?
        false
      end
    end

  end
end
