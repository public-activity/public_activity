require 'rails'
require 'active_support/dependencies'
require 'active_record'

module KeepTrack
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  autoload :Activity
  autoload :Tracked
  autoload :Creation
  autoload :VERSION
   
  included do
    class_attribute :activity_user_global
    include Tracked
  end  
  
  module ClassMethods
    def tracked(options = {})
      return if tracked?
      if options[:user]
        self.activity_user_global = options[:user]
      end
      has_many :activities, :class_name => "KeepTrack::Activity", :as => :trackable
      
      include Creation
      
    end
  end

end

ActiveRecord::Base.send :include, KeepTrack
