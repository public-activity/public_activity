module KeepTrack
  module Creation
    extend ActiveSupport::Concern
    
    included do
      after_create do
        settings = prepare_settings()
        self.activities.create(:key => "activity."+self.class.name.downcase+".create", :user_id => settings[:user], :parameters => settings[:parameters])
      end
    end   
  end
end
