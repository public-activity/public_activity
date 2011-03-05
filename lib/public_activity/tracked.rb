module PublicActivity
  # Add a flag to determine whether a model class is being tracked
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
    # This way you can pass strings that should remain constant, even when {Article}
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
    #   @article.activity_user = current_user.id #where current_user is an object of logged in user
    #   @article.save
    #   @article.activities.last.user #=> Returns User object
    attr_accessor :activity_user
    @activity_user = nil
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
    # By default, key looks like "activity.{class_name}.{create|update}"
    #
    # You can customize it, by setting your own key:
    #   @article = Article.new
    #   @article.activity_key = "my.custom.article.key"
    #   @article.save
    #   @article.activities.last.key #=> "my.custom.article.key"
    attr_accessor :activity_key
    @activity_key = nil
    # Overrides the +tracked+ method to first define the +tracked?+ class method before
    # deferring to the original +tracked+.
    module ClassMethods
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

  end
end
