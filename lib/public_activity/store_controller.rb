module PublicActivity
  # @private
  @@controllers = Hash.new
  # Lambda called after the thread is destroyed.
  Finalizer = lambda { |id|
    @@controllers.delete id
  }

  class << self
    # Setter for remembering controller instance
    def set_controller(controller)
      unless @@controllers.has_key?(Thread.current.object_id)
        ObjectSpace.define_finalizer Thread.current, Finalizer
      end if RUBY_VERSION != "1.9.3"
      @@controllers[Thread.current.object_id] = controller
    end

    # Getter for accessing the controller instance
    def get_controller
      @@controllers[Thread.current.object_id]
    end
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
