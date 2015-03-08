require 'active_support'
require 'action_view'
# +public_activity+ keeps track of changes made to models
# and allows you to display them to the users.
#
# Check {PublicActivity::Tracked::ClassMethods#tracked} for more details about customizing and specifying
# ownership to users.
module PublicActivity
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Activity,     'public_activity/models/activity'
  autoload :Activist,     'public_activity/models/activist'
  autoload :Adapter,      'public_activity/models/adapter'
  autoload :Trackable,    'public_activity/models/trackable'
  autoload :Common
  autoload :Config
  autoload :Creation,     'public_activity/actions/creation.rb'
  autoload :Deactivatable,'public_activity/roles/deactivatable.rb'
  autoload :Destruction,  'public_activity/actions/destruction.rb'
  autoload :Model
  autoload :Renderable
  autoload :Tracked,      'public_activity/roles/tracked.rb'
  autoload :Update,       'public_activity/actions/update.rb'
  autoload :VERSION

  # Switches PublicActivity on or off.
  # @param value [Boolean]
  # @since 0.5.0
  # @deprecated Use either {Deactivatable} to turn off per class or
  #             with_tracking / without_tracking helpers to turn off temporarily.
  def self.enabled=(value)
    PublicActivity.config.enabled = value
  end

  # Returns `true` if PublicActivity is on, `false` otherwise.
  # Enabled by default.
  # @return [Boolean]
  # @since 0.5.0
  def self.enabled?
    !!PublicActivity.config.enabled
  end

  # Execute the code block with PublicActiviy active
  #
  # Example usage:
  #   PublicActivity.with_tracking do
  #     # your test code here
  #   end
  def self.with_tracking
    current = PublicActivity.config.enabled
    PublicActivity.config.enabled = true
    yield
  ensure
    PublicActivity.config.enabled = current
  end

  # Execute the code block with PublicActiviy deactivated
  #
  # Example usage:
  #   PublicActivity.without_tracking do
  #     # your test code here
  #   end
  def self.without_tracking
    current = PublicActivity.config.enabled
    PublicActivity.config.enabled = false
    yield
  ensure
    PublicActivity.config.enabled = current
  end

  # Returns PublicActivity's configuration object.
  # @since 0.5.0
  def self.config
    @config ||= PublicActivity::Config.new
  end

  # Lets you set global configuration options.
  #
  # All available options and their defaults are in the example below:
  # @example Initializer for Rails
  #   PublicActivity.configure do |config|
  #     config.orm         = :active_record
  #     config.enabled     = false
  #     config.table_name  = "activities"
  #   end
  def self.configure(&block)
    yield(config) if block_given?
  end

  # Method used to choose which ORM to load
  # when PublicActivity::Activity class is being autoloaded
  def self.inherit_orm(model="Activity")
    orm = PublicActivity.config.orm
    require "public_activity/orm/#{orm.to_s}"
    "PublicActivity::ORM::#{orm.to_s.classify}::#{model}".constantize
  end
end

require 'public_activity/utility/store_controller'
require 'public_activity/utility/view_helpers'
