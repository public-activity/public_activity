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
end
