module PublicActivity
  module Destruction
    extend ActiveSupport::Concern
    
    included do
      before_destroy :activity_on_destroy
    end   
    
    module InstanceMethods
      private       
        # Records an activity upon destruction of the tracked model
        def activity_on_destroy
          settings = prepare_settings
          create_activity("activity."+self.class.name.downcase+".destroy", settings[:owner], settings[:parameters])
        end
    end
  end
end
