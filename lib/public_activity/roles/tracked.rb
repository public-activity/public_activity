# frozen_string_literal: true

module PublicActivity
  # Main module extending classes we want to keep track of.
  module Tracked
    extend ActiveSupport::Concern
    # A shortcut method for setting custom key, owner and parameters of {Activity}
    # in one line. Accepts a hash with 3 keys:
    # :key, :owner, :params. You can specify all of them or just the ones you want to overwrite.
    #
    # == Options
    #
    # [:key]
    #   See {Common#activity_key}
    # [:owner]
    #   See {Common#activity_owner}
    # [:params]
    #   See {Common#activity_params}
    # [:recipient]
    #   Set the recipient for this activity. Useful for private notifications, which should only be visible to a certain user. See {Common#activity_recipient}.
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
      rest = options.clone
      self.activity_key           = rest.delete(:key) if rest[:key]
      self.activity_owner         = rest.delete(:owner) if rest[:owner]
      self.activity_params        = rest.delete(:params) if rest[:params]
      self.activity_recipient     = rest.delete(:recipient) if rest[:recipient]
      self.activity_custom_fields = rest if rest.count > 0
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
      #    tracked :owner => proc {|o| o.author}
      #
      #   Keep in mind that owner relation is polymorphic, so you can't just
      #   provide id number of the owner object.
      # [:recipient]
      #   Specify the recipient of the {Activity}
      #   It can be a Proc, Symbol, or an ActiveRecord object
      #   == Examples:
      #
      #    tracked :recipient => :author
      #    tracked :recipient => proc {|o| o.author}
      #
      #   Keep in mind that recipient relation is polymorphic, so you can't just
      #   provide id number of the owner object.
      # [:params]
      #   Accepts a Hash with custom parameters you want to pass to i18n.translate
      #   method. It is later used in {Renderable#text} method.
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
      #   Accepts a symbol or an array of symbols, of which any combination of the three is accepted:
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
      #   Since only three options are valid,
      #   see _:except_ option for a shorter version
      # [:except]
      #   Accepts a symbol or an array of symbols with values like in _:only_, above.
      #   Values provided will be subtracted from all default actions:
      #   (create, update, destroy).
      #
      #   So, passing _create_ would track and automatically create
      #   activities on _update_ and _destroy_ actions,
      #   but not on the _create_ action.
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
      # @param opts [Hash] options
      # @return [nil] options
      def tracked(opts = {})
        options = opts.clone

        include_default_actions(options)

        assign_globals       options
        assign_hooks         options
        assign_custom_fields options

        nil
      end

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

      def available_options
        [:skip_defaults, :only, :except, :on, :owner, :recipient, :params].freeze
      end

      def assign_globals(options)
        [:owner, :recipient, :params].each do |key|
          if options[key]
            self.send("activity_#{key}_global=".to_sym, options.delete(key))
          end
        end
      end

      def assign_hooks(options)
        if options[:on].is_a?(Hash)
          self.activity_hooks = options[:on].select {|_, v| v.is_a? Proc}.symbolize_keys
        end
      end

      def assign_custom_fields(options)
        options.except(*available_options).each do |k, v|
          self.activity_custom_fields_global[k] = v
        end
      end
    end
  end
end
