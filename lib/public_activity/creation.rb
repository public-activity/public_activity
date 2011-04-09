module PublicActivity
  # Handles creation of Activities upon destruction and update of tracked model.
  module Creation
    extend ActiveSupport::Concern

    included do
      after_create :activity_on_create
      after_update :activity_on_update
    end   
    # Handlers responsible for creating Activities.
    module InstanceMethods
      private       
        # Creates activity upon creation of the tracked model
        def activity_on_create
          settings = prepare_settings
          create_activity(settings[:key] || "activity."+self.class.name.parameterize('_')+".create", settings[:owner], settings[:parameters])
        end
        
        # Creates activity upon modification of the tracked model
        def activity_on_update
          settings = prepare_settings
          create_activity(settings[:key] || "activity."+self.class.name.parameterize('_')+".update", settings[:owner], settings[:parameters])
        end
    end
  end
end
