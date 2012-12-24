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
        self.activities.create(
          :key        => options[:key],
          :owner      => options[:owner],
          :recipient  => options[:recipient],
          :parameters => options[:params]
        )
        reset_activity_instance_options
      end
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
      options = args.extract_options!
      action = (args.first || options[:action]).try(:to_s)

      key = extract_key(action, options)

      raise NoKeyProvided, "No key provided for #{self.class.name}" unless key

      # user responsible for the activity
      owner = PublicActivity.resolve_value(self,
        options[:owner] ||
        self.activity_owner ||
        self.class.activity_owner_global
      )

      # recipient of the activity
      recipient = PublicActivity.resolve_value(self,
        options[:recipient] ||
        self.activity_recipient ||
        self.class.activity_recipient_global
      )

      #customizable parameters
      params = options[:params] || {}
      params.merge!(self.class.activity_params_global)
      params.merge!(self.activity_params) if self.activity_params
      params.each { |k, v| params[k] = PublicActivity.resolve_value(self, v) }

      {
        :key        => key,
        :owner      => owner,
        :recipient  => recipient,
        :params     => params
      }
    end

    # Helper method to serialize class name into relevant key
    # @return [String] the resulted key
    # @param [Symbol] or [String] the name of the operation to be done on class
    # @param [Hash] options to be used on key generation, defaults to {}
    def extract_key(action, options = {})
      (options[:key] || self.activity_key ||
        ((self.class.name.underscore.parameterize('_') + "." + action.to_s) if action)
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
    end
  end
end
