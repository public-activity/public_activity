module KeepTrack
  module Models
    module ClassMethods
    
      def keep_track(*args)
        options = args.extract_options!
      end
      
    end
  
    module InstanceMethods
  
    end
  
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
