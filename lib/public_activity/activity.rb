require 'active_record'

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
    
    class_attribute :template

    attr_accessible :key, :owner, :parameters
    # Virtual attribute returning text description of the activity
    # using basic ERB templating
    #
    # == Example:
    #
    # Let's say you want to show article's title inside Activity message.
    #
    #   #config/pba.yml
    # activity:
    #   article:
    #     create: "New <%= trackable.name %> article has been created"
    #     update: 'Someone modified the article'
    #     destroy: 'Someone deleted the article!'
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
      begin
        erb_template = resolveTemplate(key)
        if erb_template
          parameters.merge! params
          renderer = ERB.new(erb_template)
          renderer.result(binding)
        else
          "Template not defined"
        end
      rescue
        "Template not defined"
      end
    end
    
    private
    def resolveTemplate(key)
      res = nil
      if self.template
        key.split(".").each do |k|
          res = (res ? res[k] : self.template[k])
        end
      end
      res
    end
  end  
end
