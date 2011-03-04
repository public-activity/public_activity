module KeepTrack
  module Creation
    extend ActiveSupport::Concern
    
    included do
      after_create do
        user = nil
        if not self.activity_user.nil?
          user = self.activity_user
        else
          if self.class.activity_user_global.is_a?(Symbol) or self.class.activity_user_global.is_a?(String)
            user = self[self.class.activity_user_global]
          end          
        end
        self.activities.create(:key => self.class.name.downcase+".create", :user_id => user, :parameters => self.activity_params)
      end
    end
      
  end
end
