module PublicActivity
  # Handles creation of Activities upon destruction and update of tracked model.
  module Creation
    extend ActiveSupport::Concern

    included do
      after_create :activity_on_create
    end
    private
      # Creates activity upon creation of the tracked model
      def activity_on_create
        if call_hook_safe('create')
          create_activity(prepare_settings('create'))
        end
      end
  end
end