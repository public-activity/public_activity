module PublicActivity
  # Setter for remembering controller instance
  def self.set_controller(controller)
    Thread.current[:public_activity_controller] = controller
  end

  # Getter for accessing the controller instance
  def self.get_controller
    Thread.current[:public_activity_controller]
  end

  # Module included in controllers to allow p_a access to controller instance
  module StoreController
    extend ActiveSupport::Concern

    included do
      before_filter :store_controller_for_public_activity
    end

    # Before filter executed to remember current controller
    def store_controller_for_public_activity
      PublicActivity.set_controller(self)
    end
  end
end
