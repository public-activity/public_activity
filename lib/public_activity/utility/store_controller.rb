# frozen_string_literal: true

module PublicActivity
  class << self
    # Setter for remembering controller instance
    def set_controller(controller)
      Thread.current[:public_activity_controller] = controller
    end

    # Getter for accessing the controller instance
    def get_controller
      Thread.current[:public_activity_controller]
    end
  end

  # Module included in controllers to allow p_a access to controller instance
  module StoreController
    extend ActiveSupport::Concern

    included do
      around_action :store_controller_for_public_activity if     respond_to?(:around_action)
      around_filter :store_controller_for_public_activity unless respond_to?(:around_action)
    end

    def store_controller_for_public_activity
      PublicActivity.set_controller(self)
      yield
    ensure
      PublicActivity.set_controller(nil)
    end
  end
end
