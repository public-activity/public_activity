module PublicActivity
  module Creation
    extend ActiveSupport::Concern
    
    included do
      after_create :activity_on_create
      after_update :activity_on_update
    end   
    
    module InstanceMethods
      private
        # Creates activity based on supplied arguments
        def create_activity(key, owner, params)
          self.activities.create(:key => key, :owner => owner, :parameters => params)
        end
        
        # Creates activity upon creation of the tracked model
        def activity_on_create
          settings = prepare_settings
          create_activity("activity."+self.class.name.downcase+".create", settings[:owner], settings[:parameters])
        end
        
        # Creates activity upon modification of the tracked model
        def activity_on_update
          settings = prepare_settings
          create_activity("activity."+self.class.name.downcase+".update", settings[:owner], settings[:parameters])
        end
    end
  end
end
