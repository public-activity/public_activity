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
    when Hash
      thing.dup.tap do |hash|
        hash.each do |key, value|
          hash[key] = PublicActivity.resolve_value(context, value)
        end
      end
    else
      thing
    end
  end

  # Common methods shared across the gem.
  module Common
    extend ActiveSupport::Concern

    included do
      include Trackable
      class_attribute :activity_owner_global, :activity_recipient_global,
                      :activity_parameters_global, :activity_hooks, :activity_custom_fields_global
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

    # @!attribute activity_parameters_global
    #   Global version of activity parameters
    #   @see #activity_parameters
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

    # @!visibility private
    @@activity_hooks = {}

    # @!endgroup

    # Provides some global methods for every model class.
    module ClassMethods
      #
      # @since 1.0.0
      # @api private
      def set_public_activity_class_defaults
        self.activity_owner_global             = nil
        self.activity_recipient_global         = nil
        self.activity_parameters_global        = {}
        self.activity_hooks                    = {}
        self.activity_custom_fields_global     = {}
      end

      # Extracts a hook from the _:on_ option provided in
      # {Tracked::ClassMethods#tracked}. Returns nil when no hook exists for
      # given action
      # {Common#get_hook}
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
    # Returns true if PublicActivity is enabled globally.
    # @note This method gets overwritten in {Deactivatable#public_activity_enabled?}
    # @return [Boolean]
    # @api public
    # @since 0.5.0
    # @see {Deactivatable#public_activity_enabled?}
    def public_activity_enabled?
      PublicActivity.enabled?
    end

    # Calls hook safely.
    # If a hook for given action exists, calls it with model (self) and
    # controller (if available, see {StoreController})
    # @param key (see #get_hook)
    # @return [Boolean] if hook exists, it's decision, if there's no hook, true
    # @since 0.4.0
    # @api private
    def call_hook_safe(key)
      hook = self.class.get_hook(key)
      if hook
        # provides hook with model and controller
        hook.call(self, PublicActivity.get_controller)
      else
        true
      end
    end

    # Records activity in the database, based on supplied options and configuration in
    # {Tracked}.
    #
    # If {Tracked} is used and configured for this model, `create_activity`
    # will also gather data as defined in {Tracked}. If any parameters passed here
    # conflict with options defined in {Tracked}, they get precedence over options
    # defined in {Tracked::ClassMethods#tracked}.
    #
    # Whether or not {Tracked} is used, you can provide objects, symbols and procs
    # as values for all parameters of activity. See {PublicActivity.resolve_value} for available
    # value types.
    #
    # If {Tracked} is used and hooks are provided, they will be called upon to decide
    # if this method should really record an activity. To discard defined hooks and create
    # the activity unconditionally, use {PublicActivity::Activity} directly.
    #
    # # Examples
    #     current_user.create_activity(:avatar_changed)
    #     @article.create_activity(action: :commented_on, :owner => current_user)
    #     @post.create_activity(key: 'blog_post.published', parameters: {words_count: 50})
    #
    # # Activity Key
    # The key will be generated from either:
    #
    #  * the first parameter you pass that is not a hash (`action`)
    #  * the _:action_ option in the options hash (`action`)
    #  * the _:key_ option in the options hash ( **full key** )
    #
    #  -------------------
    #  When you pass an *action* (first two options above), they will be
    #  added to parameterized model name:
    #
    # Example:
    #
    #     @article.create_activity :commented_on               #=> #<Activity key: 'article.commented_on' ...>
    #     @article.create_activity action: :commented_on       #=> #<Activity key: 'article.commented_on' ...>
    #     # note the prefix when passing in `key`
    #     @article.create_activity key: 'article.commented_on' #=> #<Activity key: 'article.commented_on' ...>
    # # Options
    # Besides `:action` and `:key` covered above, you can pass options
    # such as `:owner`, `:parameters`, `:recipient`. In addition, if you've configured any
    # *custom fields*, you can pass them in here too.
    #
    # ## Example
    #
    #     @article.create_activity :commented_on, weather_outside: :sunny
    #
    # @note This method won't create the activity if hooks reject creation.
    # @note Options passed in to this method will take precedence over defaults
    #       configured in {Tracked}.
    #
    # @return [PublicActivity::Activity, nil] If created successfully, returns new activity
    # @since 0.4.0
    # @api public
    # @overload create_activity(action, options = {})
    #   @param [Symbol,String] action Name of the action, will be prefixed
    #   @param [Hash] options Options with quality higher than instance options
    #     set in {Tracked#activity}
    #   @option options [Activist] :owner Owner
    #   @option options [Activist] :recipient Recipient
    #   @option options [Hash] :parameters Parameters, see
    #     {PublicActivity.resolve_value}
    # @overload create_activity(options = {})
    #   @param [Hash] options Options with quality higher than instance options
    #     set in {Tracked#activity}
    #   @option options [Symbol,String] :action Name of the action, will be prefixed
    #   @option options [String] :key Full key, won't be prefixed
    #   @option options [Activist] :owner Owner
    #   @option options [Activist] :recipient Recipient
    #   @option options [Hash] :parameters Parameters, see
    #     {PublicActivity.resolve_value}
    def create_activity(*args)
      return unless self.public_activity_enabled?
      options = prepare_settings(*args)

      if call_hook_safe(options[:key].split('.').last)
        return PublicActivity::Adapter.create_activity(self, options)
      end

      nil
    end

    # Prepares settings used during creation of Activity record.
    # parameters passed directly to tracked model have priority over
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
      raw_options = args.extract_options!
      action      = [args.first, raw_options.delete(:action)].compact.first
      key         = prepare_key(action, raw_options)

      raise NoKeyProvided, "No key provided for #{self.class.name}" unless key

      prepare_custom_fields(raw_options.except(:parameters, :params)).merge(
        {
          key:        key,
          owner:      prepare_relation(:owner,     raw_options),
          recipient:  prepare_relation(:recipient, raw_options),
          parameters: prepare_parameters(raw_options.delete(:parameters)),
        }
      )
    end

    # Prepares and resolves custom fields
    # users can pass to `tracked` method
    # @api private
    def prepare_custom_fields(options)
      customs = self.class.activity_custom_fields_global.clone
      customs.merge!(options)
      customs.each do  |k, v|
        customs[k] = PublicActivity.resolve_value(self, v)
      end
    end

    # Prepares i18n parameters that will
    # be serialized into the Activity#parameters column
    # @api private
    def prepare_parameters(parameters)
      parameters ||= {}

      [self.class.activity_parameters_global, parameters].reduce({}) do |params, value|
        params.merge!(PublicActivity.resolve_value(self, value))
      end
    end

    # Prepares relation to be saved
    # to Activity. Can be :recipient or :owner
    # @api private
    def prepare_relation(name, options)
      PublicActivity.resolve_value(self,
        (options.has_key?(name) ? options[name] : self.class.send("activity_#{name}_global"))
      )
    end

    # Helper method to serialize class name into relevant key
    # @return [String] the resulted key
    # @param [Symbol | String] action the name of the operation to be done on class
    # @param [Hash] options to be used on key generation, defaults to {}
    # @api private
    def prepare_key(action, options = {})
      (
        options[:key] ||
        ((self.class.name.underscore.gsub('/', '_') + "." + action.to_s) if action)
      ).try(:to_s)
    end
  end
end
