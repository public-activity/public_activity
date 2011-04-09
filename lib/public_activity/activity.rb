require 'active_record'
require 'i18n'
module PublicActivity
  # The ActiveRecord model containing 
  # details about recorded activity.
  class Activity < ActiveRecord::Base
    # Define polymorphic association to the parent
    belongs_to :trackable, :polymorphic => true
    # Define ownership to a resource responsible for this activity
    belongs_to :owner, :polymorphic => true
    # Serialize parameters Hash
    serialize :parameters, Hash
    
    # Virtual attribute returning already
    # translated key with params passed
    # to i18n.translate function. You can pass additional Hash
    # you want to be passed to translation method. It will be merged with the default ones.
    #
    # == Example:
    #
    # Let's say you want to show article's title inside Activity message.
    #
    #   #config/locales/en.yml
    #   en:
    #     activity:
    #         article:
    #           create: "Someone has created an article '%{title}'"
    #           update: "Article '%{title}' has been modified"
    #           destroy: "Someone deleted article '%{title}'!"
    #
    # And in controller:
    #
    #   def create
    #     @article = Article.new
    #     @article.title = "Rails 3.0.5 released!"
    #     @article.activity_params = {:title => @article.title}
    #     @article.save
    #   end
    #
    # Now when you list articles, you should see:
    #   @article.activities.last.text #=> "Someone has created an article 'Rails 3.0.5 released!'"
    def text(params = {})
      parameters.merge! params
      I18n.t(key, parameters || {})
    end
  end  
end
