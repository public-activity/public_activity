module KeepTrack
  module Creation
    extend ActiveSupport::Concern
    
    included do
      after_create do
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

        self.activities.create(:key => self.class.name.downcase+".create", :user_id => user, :parameters => self.activity_params)
      end
    end   
  end
end
