require 'active_support'
require 'action_view'
require 'active_record'

# +public_activity+ keeps track of changes made to models
# and allows you to display them to the users.
#
# Check {PublicActivity::Tracked::ClassMethods#tracked} for more details about customizing and specifying
# ownership to users.
module PublicActivity
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  autoload :Activist
  autoload :Activity
  autoload :Config
  autoload :Tracked
  autoload :Creation
  autoload :Update
  autoload :Destruction
  autoload :VERSION
  autoload :Common
  autoload :Renderable

  # Switches PublicActivity on or off.
  # @param value [Boolean]
  # @since 0.5.0
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

  # Returns PublicActivity's configuration object.
  # @since 0.5.0
  def self.config
    @@config ||= PublicActivity::Config.instance
  end

  # Module to be included in ActiveRecord models. Adds required functionality.
  module Model
    extend ActiveSupport::Concern
    included do
      include Tracked
      include Activist
    end
  end
end

require 'public_activity/store_controller'
require 'public_activity/view_helpers'
