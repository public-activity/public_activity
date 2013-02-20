module PublicActivity
  # Happens when creating custom activities without either action or a key.
  class NoKeyProvided < Exception; end

  # Used to smartly transform value from metadata to data.
  # Accepts Symbols, which it will send against context.
  # Accepts Procs, which it will execute with controller and context.
  # @since 0.4.0
  def self.resolve_value(context, thing)
    case thing
    when Symbol
      context.__send__(thing)
    when Proc
      thing.call(PublicActivity.get_controller, context)
    else
      thing
    end
  end

  # Common methods shared across the gem.
  module Common
    extend ActiveSupport::Concern

    included do
      ::PublicActivity.config # it's the first module to be loaded into models
                              # we need to have pieces provided by orm loaded
      include Trackable
      class_attribute :activity_owner_global, :activity_recipient_global,
                      :activity_params_global, :activity_hooks, :activity_custom_fields_global
      set_public_activity_class_defaults
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

    # Set or get custom fields for later processing
    #
    # @return [Hash]
    attr_accessor :activity_custom_fields
    @activity_custom_fields = {}

    # @!visibility private
    @@activity_hooks = {}

    # @!endgroup
    module ClassMethods
      #
      # @since 1.0.0
      # @api private
      def set_public_activity_class_defaults
        self.activity_owner_global             = nil
        self.activity_recipient_global         = nil
        self.activity_params_global            = {}
        self.activity_hooks                    = {}
        self.activity_custom_fields_global     = {}
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
    end
    #
    # Returns true if PublicActivity is enabled
    # globally and for this class.
    # @return [Boolean]
    # @api private
    # @since 0.5.0
    def public_activity_enabled?
      PublicActivity.enabled?
    end
    #
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

    # Directly creates activity record in the database, based on supplied options.
    #
    # It's meant for creating custom activities while *preserving* *all*
    # *configuration* defined before. If you fire up the simplest of options:
    #
    #   current_user.create_activity(:avatar_changed)
    #
    # It will still gather data from any procs or symbols you passed as params
    # to {Tracked::ClassMethods#tracked}. It will ask the hooks you defined
    # whether to really save this activity.
    #
    # But you can also overwrite instance and global settings with your options:
    #
    #   @article.activity :owner => proc {|controller| controller.current_user }
    #   @article.create_activity(:commented_on, :owner => @user)
    #
    # And it's smart! It won't execute your proc, since you've chosen to
    # overwrite instance parameter _:owner_ with @user.
    #
    # [:key]
    #   The key will be generated from either:
    #   * the first parameter you pass that is not a hash (*action*)
    #   * the _:action_ option in the options hash (*action*)
    #   * the _:key_ option in the options hash (it has to be a full key,
    #     including model name)
    #   When you pass an *action* (first two options above), they will be
    #   added to parameterized model name:
    #
    #   Given Article model and instance: @article,
    #
    #     @article.create_activity :commented_on
    #     @article.activities.last.key # => "article.commented_on"
    #
    # For other parameters, see {Tracked#activity}, and "Instance options"
    # accessors at {Tracked}, information on hooks is available at
    # {Tracked::ClassMethods#tracked}.
    # @see #prepare_settings
    # @return [Model, nil] If created successfully, new activity
    # @since 0.4.0
    # @api public
    # @overload create_activity(action, options = {})
    #   @param [Symbol,String] action Name of the action
    #   @param [Hash] options Options with quality higher than instance options
    #     set in {Tracked#activity}
    #   @option options [Activist] :owner Owner
    #   @option options [Activist] :recipient Recipient
    #   @option options [Hash] :params Parameters, see
    #     {PublicActivity.resolve_value}
    # @overload create_activity(options = {})
    #   @param [Hash] options Options with quality higher than instance options
    #     set in {Tracked#activity}
    #   @option options [Symbol,String] :action Name of the action
    #   @option options [String] :key Full key
    #   @option options [Activist] :owner Owner
    #   @option options [Activist] :recipient Recipient
    #   @option options [Hash] :params Parameters, see
    #     {PublicActivity.resolve_value}
    def create_activity(*args)
      return unless self.public_activity_enabled?
      options = prepare_settings(*args)

      if call_hook_safe(options[:key].split('.').last)
        reset_activity_instance_options
        return PublicActivity::Adapter.create_activity(self, options)
      end

      nil
    end

    # Prepares settings used during creation of Activity record.
    # params passed directly to tracked model have priority over
    # settings specified in tracked() method
    #
    # @see #create_activity
    # @return [Hash] Settings with preserved options that were passed
    # @api private
    # @overload prepare_settings(action, options = {})
    #   @see #create_activity
    # @overload prepare_settings(options = {})
    #   @see #create_activity
    def prepare_settings(*args)
      # key
      all_options = args.extract_options!
      options = {
        key: all_options.delete(:key),
        owner: all_options.delete(:owner),
        action: all_options.delete(:action),
        recipient: all_options.delete(:recipient),
        parameters: all_options.delete(:parameters) || all_options.delete(:params)
      }
      action = (args.first || options[:action]).try(:to_s)

      options[:key] = extract_key(action, options)

      raise NoKeyProvided, "No key provided for #{self.class.name}" unless options[:key]

      options.delete(:action)

      # user responsible for the activity
      options[:owner] = PublicActivity.resolve_value(self,
        options[:owner] ||
        self.activity_owner ||
        self.class.activity_owner_global
      )

      # recipient of the activity
      options[:recipient] = PublicActivity.resolve_value(self,
        options[:recipient] ||
        self.activity_recipient ||
        self.class.activity_recipient_global
      )

      #customizable parameters
      params = options[:params] || options[:parameters] || {}
      params.merge!(self.class.activity_params_global)
      params.merge!(self.activity_params) if self.activity_params
      params.each { |k, v| params[k] = PublicActivity.resolve_value(self, v) }
      options[:parameters] = params
      options.delete(:params)

      customs = self.class.activity_custom_fields_global.clone
      customs.merge!(self.activity_custom_fields) if self.activity_custom_fields
      customs.merge!(all_options)
      customs.each do  |k, v|
        customs[k] = PublicActivity.resolve_value(self, v)
      end.merge options
    end

    # Helper method to serialize class name into relevant key
    # @return [String] the resulted key
    # @param [Symbol] or [String] the name of the operation to be done on class
    # @param [Hash] options to be used on key generation, defaults to {}
    def extract_key(action, options = {})
      (options[:key] || self.activity_key ||
        ((self.class.name.underscore.gsub('/', '_') + "." + action.to_s) if action)
      ).try(:to_s)
    end

    # Resets all instance options on the object
    # triggered by a successful #create_activity, should not be
    # called from any other place, or from application code.
    # @private
    def reset_activity_instance_options
      @activity_params = {}
      @activity_key = nil
      @activity_owner = nil
      @activity_recipient = nil
      @activity_custom_fields = {}
    end
  end
end
