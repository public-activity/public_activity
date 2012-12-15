require 'test_helper'

class StoringController < ActionView::TestCase::TestController
  include PublicActivity::StoreController
  include ActionController::Testing::ClassMethods
end

describe PublicActivity::StoreController do
  it 'stores controller' do
    controller = StoringController.new
    PublicActivity.set_controller(controller)
    controller.must_be_same_as PublicActivity.instance_eval { class_variable_get(:@@controllers)[Thread.current.object_id] }
    controller.must_be_same_as PublicActivity.get_controller
  end

  it 'stores controller with a filter in controller' do
    controller = StoringController.new
    controller._process_action_callbacks.select {|c| c.kind == :before}.map(&:filter).must_include :store_controller_for_public_activity
    controller.instance_eval { store_controller_for_public_activity }
    controller.must_be_same_as PublicActivity.class_eval { class_variable_get(:@@controllers)[Thread.current.object_id] }
  end

  it 'stores controller in a threadsafe way' do
    reset_controllers
    PublicActivity.set_controller(1)
    PublicActivity.get_controller.must_equal 1

    a = Thread.new {
      PublicActivity.set_controller(2)
      PublicActivity.get_controller.must_equal 2
    }

    PublicActivity.get_controller.must_equal 1
    # cant really test finalizers though
  end

  private
  def reset_controllers
    PublicActivity.class_eval { class_variable_set(:@@controllers, {}) }
  end
end
