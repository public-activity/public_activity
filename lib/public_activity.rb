require 'active_support/concern'
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
# == Displaying Activities:
#
# Minimal example would be:
#
#   <% for activity in PublicActivity::Activity.all %>
#   <%= activity.text %><br/>
#   <% end %>
# Now you will need to add translations in your locale .yml, for the example
# provided above that would be:
#   en:
#     activity:
#       create: 'New article has been created'
#       update: 'Someone modified the article'
#
# Check {PublicActivity::ClassMethods#tracked} for more details about customizing and specifing
# ownership to users.
module PublicActivity
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  autoload :Activity
  autoload :Tracked
  autoload :Creation
  autoload :Destruction
  autoload :VERSION
  autoload :Common
  
  included do
    class_attribute :activity_owner_global, :activity_params_global
    self.activity_owner_global = nil
    self.activity_params_global = {}
    include Tracked
  end  
  
  module ClassMethods
    # Adds required callbacks for creating and updating
    # tracked models and adds +activities+ relation for listing
    # associated activities.
    # 
    # == Parameters:
    # :owner::
    #   You can pass a Symbol or a String with an attribute from
    #   which public_activity should take +user id+ responsible for 
    #   this activity.
    #
    #   For example:
    #    tracked :owner => :author
    #   will take +owner+ from tracked model's +author+ attribute.
    #
    #   If you need more complex logic, you can pass a Proc:
    #    tracked :owner => Proc.new{ User.first }
    # :params::
    #   Accepts a Hash containing parameters you wish
    #   to pass to every {Activity} created from this model.
    #
    #   For example, if you want to pass a parameter that
    #   should be in every {Activity}, you can do this:
    #    tracked :params => {:user_name => "Piotrek"}
    #   These params are passed to i18n.translate
    #   when using {PublicActivity::Activity#text}, which returns
    #   already translated {Activity} message.
    #   For more dynamic settings refer to {Activity} model 
    #   documentation.
    def tracked(options = {})
      return if tracked?
      include Common
      include Creation
      include Destruction
            
      if options[:owner]
        self.activity_owner_global = options[:owner]
      end
      if options[:params]
        self.activity_params_global = options[:params]
      end
      has_many :activities, :class_name => "PublicActivity::Activity", :as => :trackable      
    end
  end

end

ActiveRecord::Base.send :include, PublicActivity
