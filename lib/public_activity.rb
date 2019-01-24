# frozen_string_literal: true

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
  autoload :Renderable
  autoload :Tracked,      'public_activity/roles/tracked.rb'
  autoload :Update,       'public_activity/actions/update.rb'
  autoload :VERSION

  # Switches PublicActivity on or off.
  # @param value [Boolean]
  # @since 0.5.0
  def self.enabled=(value)
    config.enabled(value)
  end

  # Returns `true` if PublicActivity is on, `false` otherwise.
  # Enabled by default.
  # @return [Boolean]
  # @since 0.5.0
  def self.enabled?
    config.enabled
  end

  # Returns PublicActivity's configuration object.
  # @since 0.5.0
  def self.config
    @@config ||= PublicActivity::Config.instance
  end

  # Method used to choose which ORM to load
  # when PublicActivity::Activity class is being autoloaded
  def self.inherit_orm(model="Activity")
    orm = PublicActivity.config.orm
    require "public_activity/orm/#{orm.to_s}"
    "PublicActivity::ORM::#{orm.to_s.classify}::#{model}".constantize
  end

  # Module to be included in ActiveRecord models. Adds required functionality.
  module Model
    extend ActiveSupport::Concern
    included do
      include Common
      include Deactivatable
      include Tracked
      include Activist  # optional associations by recipient|owner
    end
  end
end

require 'public_activity/utility/store_controller'
require 'public_activity/utility/view_helpers'
