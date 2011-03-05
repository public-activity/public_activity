require 'rails'
require 'active_support/dependencies'
require 'active_record'
# +public_activity+ keeps track of changes made to models
# and allows for easy displaying of them.
#
# Basic usage requires adding one line to your models:
#
#   class Article < ActiveRecord::Base
#     tracked
#   end
# 
# And creating a table for activities, by doing this:
#   rails generate public_activity:migration
#   rake db:migrate
#
# Now when saved, public_activity will create 
# an Activity record containing information about that changed/created
# model.
# Check +tracked+ for more details about customizing and specifing
# ownership to users.
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
    # Adds required callbacks for creating and updating
    # tracked models and adds +activities+ relation for listing
    # associated activities.
    # 
    # == Parameters:
    # :user::
    #   You can pass a Symbol or a String with an attribute from
    #   which public_activity should take +user id+ responsible for 
    #   this activity.
    #
    #   For example:
    #    tracked :user => :author_id
    #   will take +user id+ from tracked model's +author_id+ attribute.
    #
    #   If you need more complex logic, you can pass a Proc:
    #    tracked :user => Proc.new{ User.first.id }
    # :params::
    #   Accepts a Hash containing parameters you wish
    #   to pass to every {Activity} created from this model.
    #
    #   For example, if you want to pass a parameter that
    #   should be in every {Activity}, you can do this:
    #    tracked :params => {:user_name => "Piotrek"}
    #   For more dynamic settings refer to [Activity] model 
    #   documentation.
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
