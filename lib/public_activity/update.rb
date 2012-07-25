module PublicActivity
  # Handles creation of Activities upon destruction and update of tracked model.
  module Update
    extend ActiveSupport::Concern

    included do
      after_update :activity_on_update
    end
    private
      # Creates activity upon modification of the tracked model
      def activity_on_update
        if call_hook_safe('update')
          create_activity(prepare_settings('update'))
        end
      end
  end
end
