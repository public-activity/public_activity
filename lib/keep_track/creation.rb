module KeepTrack
  module Creation
    extend ActiveSupport::Concern
    
    included do
      after_create do
        self.activities.create(:key => "testowy", :parameters => {:costam => "wartosc"})
      end
    end
      
  end
end
