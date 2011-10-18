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
      if !self.template.nil?
        parameters.merge! params
        renderer = ERB.new(resolveTemplate(key))
        renderer.result(binding)
      else
        "Template not defined"
      end
    end
    
    private
    def resolveTemplate(key)
       res = nil
       key.split(".").each do |k|
         if res.nil?
           res = self.template[k]
         else
           res = res[k]
         end
       end
       res
    end
    
  end  
end
