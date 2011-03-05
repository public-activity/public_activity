require 'rails'
require 'active_support/dependencies'
require 'active_record'

module PublicActivity
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  autoload :Activity
  autoload :Tracked
  autoload :Creation
  autoload :VERSION
  autoload :Common
  
  included do
    class_attribute :activity_user_global, :activity_params_global
    self.activity_user_global = nil
    self.activity_params_global = {}
    include Tracked
  end  
  
  module ClassMethods
    def tracked(options = {})
      return if tracked?
      include Creation
      include Common
      
      if options[:user]
        self.activity_user_global = options[:user]
      end
      if options[:params]
        self.activity_params_global = options[:params]
      end
      has_many :activities, :class_name => "PublicActivity::Activity", :as => :trackable
      
      
      
    end
  end

end

ActiveRecord::Base.send :include, PublicActivity
