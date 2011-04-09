module PublicActivity
  # Common methods shared across the gem.
  module Common
    extend ActiveSupport::Concern
    # Instance methods used by other methods in PublicActivity module.
    module InstanceMethods
      private
        # Creates activity based on supplied arguments
        def create_activity(key, owner, params)
          self.activities.create(:key => key, :owner => owner, :parameters => params)
        end
        # Prepares settings used during creation of Activity record.
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
          return {:key => self.activity_key,:owner => owner, :parameters => parameters}
        end      
    end
  end
end
