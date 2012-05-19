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
    # Set or get owner object responsible for the {Activity}.
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
    #   @article.activity_owner = current_user # where current_user is an object of logged in user
    #   @article.activity_owner = :author # OR: take @article.author attribute
    #   @article.activity_owner = proc {|o| o.author } # OR: provide a Proc with custom code
    #   @article.save
    #   @article.activities.last.owner #=> Returns owner object
    attr_accessor :activity_owner
    @activity_owner = nil
    # Set or get custom i18n key passed to {Activity}, later used in {Activity#text}
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
    # By default, key looks like "activity.class_name.create|update|destroy"
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
      # [:owner]
      #   Specify the owner of the {Activity} (person responsible for the action).
      #   It can be a Proc, Symbol or an ActiveRecord object:
      #   == Examples:
      #    @article.activity :owner => :author    
      #    @article.activity :owner => {|o| o.author}
      #    @article.activity :owner => User.where(:login => 'piotrek').first
      #   Keep in mind that owner relation is polymorphic, so you can't just provide id number of the owner object.
      # [:params]
      #   Accepts a Hash with custom parameters you want to pass to i18n.translate
      #   method. It is later used in {Activity#text} method.
      #   == Example:
      #    @article.activity :parameters => {:title => @article.title, :short => truncate(@article.text, :length => 50)}
      #   Everything specified here has a lower priority than parameters specified directly in {#activity} method.
      #   So treat it as a place where you provide 'default' values.
      #   For more dynamic settings refer to {Activity} model 
      #   documentation.
      # [:skip_defaults]
      #   Disables recording of activities on create/update/destroy leaving that to programmer's choice. Check {PublicActivity::Common#create_activity}
      #   for a guide on how to manually record activities.
      def tracked(options = {})
        include Common
        
        all_options = [:create, :update, :destroy]
        
        if !options[:skip_defaults] && !options[:only] && !options[:except] 
          include Creation
          include Destruction
          include Update
        end
        
        if options[:except].is_a? Array
          options[:only] = all_options - options[:except]
        end
        
        if options[:only].is_a? Array
            options[:only].each do |opt|
              if opt.eql?(:create)
                include Creation
              elsif opt.eql?(:destroy)
                include Destruction
              elsif opt.eql?(:update)
                include Update
              end
            end
        end
            
        if options[:owner]
          self.activity_owner_global = options[:owner]
        end
        if options[:params]
          self.activity_params_global = options[:params]
        end
        has_many :activities, :class_name => "PublicActivity::Activity", :as => :trackable      
      end
    end
    
    # A shortcut method for setting custom key, owner and parameters of {Activity}
    # in one line. Accepts a hash with 3 keys:
    # :key, :owner, :params. You can specify all of them or just the ones you want to overwrite.
    #
    # === Options
    #
    # [:key]
    #   Accepts a string that will be used as a i18n key for {Activity#text} method.
    # [:owner]
    #   Specify the owner of the {Activity} (person responsible for the action).
    #   It can be a Proc, Symbol or an ActiveRecord object:
    #   == Examples:
    #    @article.activity :owner => :author
    #    @article.activity :owner => {|o| o.author}
    #    @article.activity :owner => User.where(:login => 'piotrek').first
    #   Keep in mind that owner relation is polymorphic, so you can't just provide id number of the owner object.
    # [:params]
    #   Accepts a Hash with custom parameters you want to pass to i18n.translate
    #   method. It is later used in {Activity#text} method.
    #   == Example:
    #    @article.activity :parameters => {:title => @article.title, :short => truncate(@article.text, :length => 50)}
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
