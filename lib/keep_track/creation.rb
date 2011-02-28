module KeepTrack
  module Creation
    extend ActiveSupport::Concern
    
    included do
      after_create :save_activity
    end
  
    module InstanceMethods
      private
      def save_activity
        activities.create(:key => "testowy", :parameters => {:costam => "wartosc"})      
      end
    end    
  end
end
