module PublicActivity
  # Main module extending classes we want to keep track of.
  module Tracked
    extend ActiveSupport::Concern

    # Module with basic +tracked+ method that enables tracking models.
    module ClassMethods
      # Adds required callbacks for creating and updating
      # tracked models and adds +activities+ relation for listing
      # associated activities.
      #
      # Everything specified here has a lower priority than parameters
      # specified directly in {#create_activity} method.
      #
      # So treat it as a place where you provide 'default' values or where you
      # specify what data should be gathered for every activity.
      #
      # ## Parameters:
      #
      # See {PublicActivity.resolve_value} types of values you can pass in here.
      #
      # - `:owner`
      #
      #     Specify the owner of the {Activity} (person responsible for the action).
      #     It can be a Proc, Symbol or an ActiveRecord object:
      #
      # - `:recipient`
      #
      #     Specify the recipient of the {Activity}
      #     It can be a Proc, Symbol, or an ActiveRecord object
      #
      # - `:parameters`
      #
      #     Accepts a Hash with custom parameters you want to pass to i18n.translate
      #     method. It is later used in {Renderable#text} method.
      #     == Example:
      #
      #         class Article < ActiveRecord::Base
      #           include PublicActivity::Model
      #           tracked parameters: {
      #               title: :title,
      #               author_name: "Michael",
      #               category_name: -> _, model { model.category.name },
      #               summary: -> _, model { truncate(model.text, length: 30)
      #           }
      #         end
      #
      # - `:skip_defaults`
      #
      #     Disables recording of activities on create/update/destroy leaving that to programmer's choice. Check {PublicActivity::Common#create_activity}
      #     for a guide on how to manually record activities.
      #
      # - `:only`
      #
      #     Symbol or an array of symbols, of which any combination of the three is recognized:
      #     * `:create`
      #     * `:update`
      #     * `:destroy`
      #
      #     Selecting one or more of these will make PublicActivity create activities
      #     automatically for the tracked model on selected actions.
      #
      #     Resulting activities will have have keys assigned to, respectively:
      #     * `article.create`
      #     * `article.update`
      #     * `article.destroy`
      #
      #     Since only three options are valid,
      #     see `:except` option for a shorter version
      #
      # - `:except`
      #
      #     Accepts a symbol or an array of symbols with values like in `:only`, above.
      #     Values provided will be subtracted from all default actions:
      #     (create, update, destroy).
      #
      #     So, passing _create_ would track and automatically create
      #     activities on _update_ and _destroy_ actions,
      #     but not on the _create_ action.
      #
      # - `:on`
      #
      #     Hash with keys being the *action* on which to execute *value* (proc)
      #     Currently supported only for CRUD actions which are enabled in _:only_
      #     or _:except_ options on this method.
      #
      #     Key-value pairs in this option define callbacks that will decide
      #     whether to create an activity or not. Procs have two attributes for
      #     use: _model_ and _controller_. If the proc returns true, the activity
      #     will be created, if not, then activity will not be saved.
      #
      #     ### Example:
      #
      #         # app/models/article.rb
      #         tracked on: {update: -> _, model { model.published? } }
      #
      #     In the example above, given a model Article with boolean column _published_.
      #     The activities with key _article.update_ will only be created
      #     if the published status is set to true on that article.
      # @param opts [Hash] options
      # @return [nil] options
      def tracked(opts = {})
        options = opts.clone

        include_default_actions(options)

        assign_globals       options
        assign_hooks         options
        assign_custom_fields options
      end

      # @api private
      def include_default_actions(options)
        defaults = {
          create:  Creation,
          destroy: Destruction,
          update:  Update
        }

        if options[:skip_defaults] == true
          return
        end

        modules = if options[:except]
          defaults.except(*options[:except])
        elsif options[:only]
          defaults.slice(*options[:only])
        else
          defaults
        end

        modules.each do |key, value|
          include value
        end
      end

      # @api private
      def available_options
        [:skip_defaults, :only, :except, :on, :owner, :recipient, :parameters].freeze
      end

      # @api private
      def assign_globals(options)
        [:owner, :recipient, :parameters].each do |key|
          if options[key]
            self.send("activity_#{key}_global=".to_sym, options.delete(key))
          end
        end
      end

      # @api private
      def assign_hooks(options)
        if options[:on].is_a?(Hash)
          self.activity_hooks = options[:on].select {|_, v| v.is_a? Proc}.symbolize_keys
        end
      end

      # @api private
      def assign_custom_fields(options)
        options.except(*available_options).each do |k, v|
          self.activity_custom_fields_global[k] = v
        end
      end
    end
  end
end
