module KeepTrack
  module Common
    extend ActiveSupport::Concern
    
    module InstanceMethods
      # Prepare settings used during creation of Activity record.
      # params passed directly to tracked model have priority over
      # settings specified in tracked() method
      def prepare_settings
        # user responsible for the activity
        if self.activity_user
          user = self.activity_user
        else
          case self.activity_user_global
            when Symbol, String 
              user = self[self.class.activity_user_global]
            when Proc
              user = self.class.activity_user_global.call           
          end
        end
        #customizable parameters
        parameters = self.class.activity_params_global
        parameters.merge! self.activity_params        
        return {:user => user, :parameters => parameters}
      end
      
    end
  end
end
