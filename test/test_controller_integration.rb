require 'test_helper'

class StoringController < ActionView::TestCase::TestController
  include PublicActivity::StoreController
  include ActionController::Testing::ClassMethods
end

class TestStoreController < MiniTest::Unit::TestCase
  def test_storing_controller
    controller = StoringController.new
    PublicActivity.set_controller(controller)
    assert_equal controller, PublicActivity.instance_eval { class_variable_get(:@@controllers)[Thread.current.object_id] }
    assert_equal controller, PublicActivity.get_controller
  end

  def test_extending_controller
    controller = StoringController.new
    assert_includes controller._process_action_callbacks.select {|c| c.kind == :before}.map(&:filter), :store_controller_for_public_activity
    controller.instance_eval { store_controller_for_public_activity }
    assert_equal controller, PublicActivity.class_eval { class_variable_get(:@@controllers)[Thread.current.object_id] }
  end

  def test_threadsafe_controller_storage
    reset_controllers
    PublicActivity.set_controller(1)
    assert_equal 1, PublicActivity.get_controller

    a = Thread.new {
      PublicActivity.set_controller(2)
      assert_equal 2, PublicActivity.get_controller
    }

    assert_equal 1, PublicActivity.get_controller
    # cant really test finalizers though
  end

  private
  def reset_controllers
    PublicActivity.class_eval { class_variable_set(:@@controllers, {}) }
  end
end
