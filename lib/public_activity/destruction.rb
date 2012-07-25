module PublicActivity
  # Handles creation of Activities upon destruction of tracked model.
  module Destruction
    extend ActiveSupport::Concern

    included do
      before_destroy :activity_on_destroy
    end
    private
      # Records an activity upon destruction of the tracked model
      def activity_on_destroy
        if call_hook_safe('destroy')
          create_activity(prepare_settings('destroy'))
        end
      end
  end
end
