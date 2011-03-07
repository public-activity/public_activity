module PublicActivity
  module Common
    extend ActiveSupport::Concern
    
    module InstanceMethods
      # Prepare settings used during creation of Activity record.
      # params passed directly to tracked model have priority over
      # settings specified in tracked() method
      def prepare_settings
        # user responsible for the activity
        if self.activity_owner
          owner = self.activity_owner
        else
          case self.activity_owner_global
            when Symbol, String 
              owner = self[self.class.activity_owner_global]
            when Proc
              owner = self.class.activity_owner_global.call           
          end
        end
        #customizable parameters
        parameters = self.class.activity_params_global
        parameters.merge! self.activity_params if self.activity_params      
        return {:owner => owner, :parameters => parameters}
      end
      
    end
  end
end
