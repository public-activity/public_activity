module PublicActivity
  class << self
    def set_controller(controller)
      Thread.current[:controller] = controller
    end

    def get_controller
      Thread.current[:controller]
    end
  end

  module StoreController
    extend ActiveSupport::Concern

    included do
      before_filter :store_controller_for_public_activity
    end

    def store_controller_for_public_activity
      PublicActivity.set_controller(self)
    end
  end
end
