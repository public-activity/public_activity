module PublicActivity
  # Main module extending classes we want to keep track of.
  module Tracked
    extend ActiveSupport::Concern

    included do
      class_attribute :activity_owner_global, :activity_params_global, :activity_hooks
      self.activity_owner_global = nil
      self.activity_params_global = {}
      self.activity_hooks = {}
    end
    # Set or get parameters that will be passed to {Activity} when saving
    #
    # == Usage:
    #
    #   @article.activity_params = {:article_title => @article.title}
    #   @article.save
    #
    # This way you can pass strings that should remain constant, even when model attributes
    # change after creating this {Activity}.
    attr_accessor :activity_params
    @activity_params = {}
    # Set or get owner object responsible for the {Activity}.
    #
    # == Usage:
    #
    #   # where current_user is an object of logged in user
    #   @article.activity_owner = current_user
    #   # OR: take @article.author association
    #   @article.activity_owner = :author
    #   # OR: provide a Proc with custom code
    #   @article.activity_owner = proc {|controller, model| model.author }
    #   @article.save
    #   @article.activities.last.owner #=> Returns owner object
    attr_accessor :activity_owner
    @activity_owner = nil

    # Set or get recipient for activity.
    #
    # Association is polymorphic, thus allowing assignment of
    # all types of models. This can be used for example in the case of sending
    # private notifications for only a single user.
    #
    # Note: Unlike other variables, recipient can only be assigned on the
    # tracked model's instance.
    attr_accessor :activity_recipient
    @activity_recipient = nil
    # Set or get custom i18n key passed to {Activity}, later used in {Activity#text}
    #
    # == Usage:
    #
    # @article = Article.new
    # @article.activity_key = "my.custom.article.key"
    # @article.save
    # @article.activities.last.key #=> "my.custom.article.key"
    #
    attr_accessor :activity_key
    @activity_key = nil

    # Hooks/functions that will be used to decide *if* the activity should get
    # created.
    #
    # The supported keys are:
    # * :create
    # * :update
    # * :destroy
    @@activity_hooks = {}

    # A shortcut method for setting custom key, owner and parameters of {Activity}
    # in one line. Accepts a hash with 3 keys:
    # :key, :owner, :params. You can specify all of them or just the ones you want to overwrite.
    #
    # == Options
    #
    # [:key]
    #   See {#activity_key}
    # [:owner]
    #   See {#activity_owner}
    # [:params]
    #   See {#activity_params}
    # [:recipient]
    #   Set the recipient for this activity. Useful for private notifications, which should only be visible to a certain user. See {#activity_recipient}.
    # @example
    #
    #   @article = Article.new
    #   @article.title = "New article"
    #   @article.activity :key => "my.custom.article.key", :owner => @article.author, :params => {:title => @article.title}
    #   @article.save
    #   @article.activities.last.key #=> "my.custom.article.key"
    #   @article.activities.last.parameters #=> {:title => "New article"}
    #
    def activity(options = {})
      self.activity_key = options[:key] if options[:key]
      self.activity_owner = options[:owner] if options[:owner]
      self.activity_params = options[:params] if options[:params]
      self.activity_recipient = options[:recipient] if options[:recipient]
    end

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
      #
      #    tracked :owner => :author
      #    tracked :owner => {|o| o.author}
      #
      #   Keep in mind that owner relation is polymorphic, so you can't just provide id number of the owner object.
      # [:params]
      #   Accepts a Hash with custom parameters you want to pass to i18n.translate
      #   method. It is later used in {Activity#text} method.
      #   == Example:
      #    class Article < ActiveRecord::Base
      #      include PublicActivity::Model
      #      tracked :params => {
      #          :title => :title,
      #          :author_name => "Michael",
      #          :category_name => proc {|controller, model_instance| model_instance.category.name},
      #          :summary => proc {|controller, model_instance| truncate(model.text, :length => 30)}
      #      }
      #    end
      #
      #   Values in the :params hash can either be an *exact* *value*, a *Proc/Lambda* executed before saving the activity or a *Symbol*
      #   which is a an attribute or a method name executed on the tracked model's instance.
      #
      #   Everything specified here has a lower priority than parameters specified directly in {#activity} method.
      #   So treat it as a place where you provide 'default' values.
      #   For more dynamic settings refer to {Activity} model documentation.
      # [:skip_defaults]
      #   Disables recording of activities on create/update/destroy leaving that to programmer's choice. Check {PublicActivity::Common#create_activity}
      #   for a guide on how to manually record activities.
      def tracked(options = {})
        include Common

        all_options = [:create, :update, :destroy]

        if !options.has_key?(:skip_defaults) && !options[:only] && !options[:except]
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
        if options.has_key?(:on) and options[:on].is_a? Hash
          self.activity_hooks = options[:on].delete_if {|_, v| !v.is_a? Proc}.symbolize_keys if RUBY_VERSION == "1.8.7"
          self.activity_hooks = options[:on].select {|_, v| v.is_a? Proc}.symbolize_keys if RUBY_VERSION != "1.8.7"
        end
        has_many :activities, :class_name => "PublicActivity::Activity", :as => :trackable
      end

      # Returns instance hook for given key
      def get_hook(key)
        key = key.to_sym
        if self.activity_hooks.has_key?(key) and self.activity_hooks[key].is_a? Proc
          return self.activity_hooks[key]
        end
        return nil
      end
    end

    # Returns class hook for given key
    def get_hook(key)
      self.class.get_hook(key)
    end

    # Safely calls hook for given key
    def call_hook_safe(key)
      hook = self.get_hook(key)
      if hook
        # provides hook with model and controller
        hook.call(self, PublicActivity.get_controller)
      else
        return true
      end
    end
  end
end
