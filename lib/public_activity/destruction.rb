module PublicActivity
  # Handles creation of Activities upon destruction of tracked model.
  module Destruction
    extend ActiveSupport::Concern
    
    included do
      before_destroy :activity_on_destroy
    end   
    # Handlers responsible for adding {Activity} when object is destroyed.
    module InstanceMethods
      private       
        # Records an activity upon destruction of the tracked model
        def activity_on_destroy
          settings = prepare_settings
          create_activity("activity."+self.class.name.parameterize('_')+".destroy", settings[:owner], settings[:parameters])
        end
    end
  end
end
