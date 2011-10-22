require 'active_support/concern'
require 'active_support/dependencies'
require 'active_record'
require 'pusher'
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
#       destroy: 'Someone deleted the article!'
#
# Check {PublicActivity::ClassMethods#tracked} for more details about customizing and specifing
# ownership to users.
module PublicActivity
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  autoload :Activist
  autoload :Activity
  autoload :Tracked
  autoload :Creation
  autoload :Update  
  autoload :Destruction
  autoload :VERSION
  autoload :Common
  
  included do
    include Tracked
    include Activist 
  end  
end

ActiveRecord::Base.send :include, PublicActivity
