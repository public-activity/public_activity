module PublicActivity
  @@controllers = Hash.new

  class << self
    def set_controller(controller)
      @@controllers[Thread.current.object_id] = controller
    end

    def get_controller
      @@controllers[Thread.current.object_id]
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
