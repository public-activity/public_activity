module KeepTrack
  module Creation
    extend ActiveSupport::Concern
    
    included do
      after_create do
        self.activities.create(:key => self.class.name.downcase+".create", :user => self.activity_user, :parameters => self.activity_params)
      end
    end
      
  end
end
