module PublicActivity
  # Main module extending classes we want to keep track of.
  module Tracked
    extend ActiveSupport::Concern
    
    included do
      class_attribute :activity_owner_global, :activity_params_global
      self.activity_owner_global = nil
      self.activity_params_global = {}
    end  
    # Set or get parameters that will be passed to {Activity} when saving
    #
    # == Usage:
    # In model:
    #
    #   class Article < ActiveRecord::Base
    #     tracked
    #   end 
    #
    # In controller
    #   @article = Article.new
    #   @article.activity_params = {:article_title => @article.title}
    #   @article.save
    # This way you can pass strings that should remain constant, even when Article
    # changes after creating this {Activity}.
    attr_accessor :activity_params
    @activity_params = {}
    # Set or get user id responsible for the {Activity}.
    # Same rules apply like with the other attributes described.
    #
    # == Usage:
    # In model:
    #
    #   class Article < ActiveRecord::Base
    #     tracked
    #   end 
    # Controller:
    #
    #   @article = Article.new
    #   @article.activity_owner = current_user #where current_user is an object of logged in user
    #   @article.save
    #   @article.activities.last.user #=> Returns User object
    attr_accessor :activity_owner
    @activity_owner = nil
    # Set or get custom i18n key passed to {Activity}
    #
    # == Usage:
    # In model:
    #
    #   class Article < ActiveRecord::Base
    #     tracked
    #   end 
    #
    # In controller:
    #
    #   @article = Article.new
    #   @article.save
    #   @article.activities.last.key #=> "activity.article.create"
    # By default, key looks like "activity.[class_name].[create|update|destroy]"
    #
    # You can customize it, by setting your own key:
    #   @article = Article.new
    #   @article.activity_key = "my.custom.article.key"
    #   @article.save
    #   @article.activities.last.key #=> "my.custom.article.key"
    attr_accessor :activity_key
    @activity_key = nil
    
    # Module with basic +tracked+ method that enables tracking models.
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
    
    # A module with shortcut method for setting own parameters to the {Activity} model
    module InstanceMethods
    # A shortcut method for setting custom key, owner and parameters of {Activity}
    # in one line. Accepts a hash with 3 keys:
    # :key, :owner, :params. You can specify all of them or just the ones you want to overwrite.
    #
    # == Usage:
    # In model:
    #
    #   class Article < ActiveRecord::Base
    #     tracked
    #   end 
    #
    # In controller:
    #
    #   @article = Article.new
    #   @article.title = "New article"    
    #   @article.activity :key => "my.custom.article.key", :owner => @article.author, :params => {:title => @article.title}
    #   @article.save
    #   @article.activities.last.key #=> "my.custom.article.key"
    #   @article.activities.last.parameters #=> {:title => "New article"}
      def activity(options = {}) 
        self.activity_key = options[:key] if options[:key]      
        self.activity_owner = options[:owner] if options[:owner]
        self.activity_params = options[:params] if options[:params]
      end
    end
    
  end
end
