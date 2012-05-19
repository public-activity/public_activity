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
        settings = prepare_settings
        create_activity(settings[:key] || "activity."+self.class.name.parameterize('_')+".create", settings[:owner], settings[:parameters])
      end
  end
end
