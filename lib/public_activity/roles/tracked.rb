module PublicActivity
  # Main module extending classes we want to keep track of.
  module Tracked
    extend ActiveSupport::Concern

    included do
      class_attribute :activity_owner_global, :activity_recipient_global,
                      :activity_params_global, :activity_hooks, :public_activity_enabled_for_model
      self.activity_owner_global             = nil
      self.activity_recipient_global         = nil
      self.activity_params_global            = {}
      self.activity_hooks                    = {}
      self.public_activity_enabled_for_model = true
    end

    # @!group Global options

    # @!attribute activity_owner_global
    #   Global version of activity owner
    #   @see #activity_owner
    #   @return [Model]

    # @!attribute activity_recipient_global
    #   Global version of activity recipient
    #   @see #activity_recipient
    #   @return [Model]

    # @!attribute activity_params_global
    #   Global version of activity parameters
    #   @see #activity_params
    #   @return [Hash<Symbol, Object>]

    # @!attribute activity_hooks
    #   @return [Hash<Symbol, Proc>]
    #   Hooks/functions that will be used to decide *if* the activity should get
    #   created.
    #
    #   The supported keys are:
    #   * :create
    #   * :update
    #   * :destroy

    # @!endgroup

    # @!group Instance options

    # Set or get parameters that will be passed to {Activity} when saving
    #
    # == Usage:
    #
    #   @article.activity_params = {:article_title => @article.title}
    #   @article.save
    #
    # This way you can pass strings that should remain constant, even when model attributes
    # change after creating this {Activity}.
    # @return [Hash<Symbol, Object>]
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
    # @return [Model] Polymorphic model
    # @see #activity_owner_global
    attr_accessor :activity_owner
    @activity_owner = nil

    # Set or get recipient for activity.
    #
    # Association is polymorphic, thus allowing assignment of
    # all types of models. This can be used for example in the case of sending
    # private notifications for only a single user.
    # @return (see #activity_owner)
    attr_accessor :activity_recipient
    @activity_recipient = nil
    # Set or get custom i18n key passed to {Activity}, later used in {Activity#text}
    #
    # == Usage:
    #
    #   @article = Article.new
    #   @article.activity_key = "my.custom.article.key"
    #   @article.save
    #   @article.activities.last.key #=> "my.custom.article.key"
    #
    # @return [String]
    attr_accessor :activity_key
    @activity_key = nil

    # @!visibility private
    @@activity_hooks = {}

    # @!endgroup

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
    # @param options [Hash] instance options to set on the tracked model
    # @return [nil]
    def activity(options = {})
      self.activity_key = options[:key] if options[:key]
      self.activity_owner = options[:owner] if options[:owner]
      self.activity_params = options[:params] if options[:params]
      self.activity_recipient = options[:recipient] if options[:recipient]
      nil
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
      #   Keep in mind that owner relation is polymorphic, so you can't just
      #   provide id number of the owner object.
      # [:recipient]
      #   Specify the recipient of the {Activity}
      #   It can be a Proc, Symbol, or an ActiveRecord object
      #   == Examples:
      #
      #    tracked :recipient => :author
      #    tracked :recipient => {|o| o.author}
      #
      #   Keep in mind that recipient relation is polymorphic, so you can't just
      #   provide id number of the owner object.
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
      #   Everything specified here has a lower priority than parameters
      #   specified directly in {#activity} method.
      #   So treat it as a place where you provide 'default' values or where you
      #   specify what data should be gathered for every activity.
      #   For more dynamic settings refer to {Activity} model documentation.
      # [:skip_defaults]
      #   Disables recording of activities on create/update/destroy leaving that to programmer's choice. Check {PublicActivity::Common#create_activity}
      #   for a guide on how to manually record activities.
      # [:only]
      #   Accepts array of symbols, of which correct is any combination of the three:
      #   * _:create_
      #   * _:update_
      #   * _:destroy_
      #   Selecting one or more of these will make PublicActivity create activities
      #   automatically for the tracked model on selected actions.
      #
      #   Resulting activities will have have keys assigned to, respectively:
      #   * _article.create_
      #   * _article.update_
      #   * _article.destroy_
      #   Since only three options are valid in this array,
      #   see _:except_ option for a shorter version
      # [:except]
      #   Accepts array of symbols with values like in _:only_, above.
      #   Values provided will be subtracted from all default actions:
      #   (create, update, destroy).
      #
      #   So, passing _create_ would track and automatically create
      #   activities on _update_ and _destroy_ actions.
      # [:on]
      #   Accepts a Hash with key being the *action* on which to execute *value* (proc)
      #   Currently supported only for CRUD actions which are enabled in _:only_
      #   or _:except_ options on this method.
      #
      #   Key-value pairs in this option define callbacks that can decide
      #   whether to create an activity or not. Procs have two attributes for
      #   use: _model_ and _controller_. If the proc returns true, the activity
      #   will be created, if not, then activity will not be saved.
      #
      #   == Example:
      #     # app/models/article.rb
      #     tracked :on => {:update => proc {|model, controller| model.published? }}
      #
      #   In the example above, given a model Article with boolean column _published_.
      #   The activities with key _article.update_ will only be created
      #   if the published status is set to true on that article.
      # @param options [Hash] options
      # @return [nil] options
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
        if options[:recipient]
          self.activity_recipient_global = options[:recipient]
        end
        if options[:params]
          self.activity_params_global = options[:params]
        end
        if options.has_key?(:on) and options[:on].is_a? Hash
          self.activity_hooks = options[:on].delete_if {|_, v| !v.is_a? Proc}.symbolize_keys if RUBY_VERSION == "1.8.7"
          self.activity_hooks = options[:on].select {|_, v| v.is_a? Proc}.symbolize_keys if RUBY_VERSION != "1.8.7"
        end
        has_many :activities, :class_name => "::PublicActivity::Activity", :as => :trackable

        nil
      end

      # Extracts a hook from the _:on_ option provided in
      # {Tracked::ClassMethods#tracked}. Returns nil when no hook exists for
      # given action
      # {Tracked#get_hook}
      #
      # @see Tracked#get_hook
      # @param key [String, Symbol] action to retrieve a hook for
      # @return [Proc, nil] callable hook or nil
      # @since 0.4.0
      # @api private
      def get_hook(key)
        key = key.to_sym
        if self.activity_hooks.has_key?(key) and self.activity_hooks[key].is_a? Proc
          self.activity_hooks[key]
        else
          nil
        end
      end

      # Switches public_activity off for this class
      def public_activity_off
        self.public_activity_enabled_for_model = false
      end

      # Switches public_activity on for this class
      def public_activity_on
        self.public_activity_enabled_for_model = true
      end
    end

    # Returns true if PublicActivity is enabled
    # globally and for this class.
    # @return [Boolean]
    # @api private
    # @since 0.5.0
    def public_activity_enabled?
      PublicActivity.enabled? && self.class.public_activity_enabled_for_model
    end

    # Shortcut for {Tracked::ClassMethods#get_hook}
    # @param (see Tracked::ClassMethods#get_hook)
    # @return (see Tracked::ClassMethods#get_hook)
    # @since (see Tracked::ClassMethods#get_hook)
    # @api (see Tracked::ClassMethods#get_hook)
    def get_hook(key)
      self.class.get_hook(key)
    end

    # Calls hook safely.
    # If a hook for given action exists, calls it with model (self) and
    # controller (if available, see {StoreController})
    # @param key (see #get_hook)
    # @return [Boolean] if hook exists, it's decision, if there's no hook, true
    # @since 0.4.0
    # @api private
    def call_hook_safe(key)
      hook = self.get_hook(key)
      if hook
        # provides hook with model and controller
        hook.call(self, PublicActivity.get_controller)
      else
        true
      end
    end
  end
end
