# frozen_string_literal: true

module PublicActivity
  # Enables per-class disabling of PublicActivity functionality.
  module Deactivatable
    extend ActiveSupport::Concern

    included do
      class_attribute :public_activity_enabled_for_model
      set_public_activity_class_defaults
    end

    # Returns true if PublicActivity is enabled
    # globally and for this class.
    # @return [Boolean]
    # @api private
    # @since 0.5.0
    # overrides the method from Common
    def public_activity_enabled?
      PublicActivity.enabled? && self.class.public_activity_enabled_for_model
    end

    # Provides global methods to disable or enable PublicActivity on a per-class
    # basis.
    module ClassMethods
      # Switches public_activity off for this class
      def public_activity_off
        self.public_activity_enabled_for_model = false
      end

      # Switches public_activity on for this class
      def public_activity_on
        self.public_activity_enabled_for_model = true
      end

      # @since 1.0.0
      # @api private
      def set_public_activity_class_defaults
        super
        self.public_activity_enabled_for_model = true
      end
    end
  end
end
