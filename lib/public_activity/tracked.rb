module PublicActivity
  # Main module extending classes we want to keep track of.
  module Tracked
    extend ActiveSupport::Concern

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
    # Placeholder methods for classes not tracked by public_activity gem.
    module ClassMethods
    # Overrides the +tracked+ method to first define the +tracked?+ class method before
    # deferring to the original +tracked+.
      def tracked(*args)
        super(*args)

        class << self
          def tracked?
            true
          end
        end
      end

      # For ActiveRecord::Base models that do not call the +tracked+ method, the +tracked?+
      # will return false
      def tracked?
        false
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
