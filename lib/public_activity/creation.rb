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
        def create_activity(key, user_id, params)
          self.activities.create(:key => key, :user_id => user_id, :parameters => params)
        end
        
        # Creates activity upon creation of the tracked model
        def activity_on_create
          settings = prepare_settings
          create_activity("activity."+self.class.name.downcase+".create", settings[:user], settings[:parameters])
        end
        
        # Creates activity upon modification of the tracked model
        def activity_on_update
          settings = prepare_settings
          create_activity("activity."+self.class.name.downcase+".update", settings[:user], settings[:parameters])
        end
    end
  end
end
