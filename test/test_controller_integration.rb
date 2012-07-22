require 'test_helper'

class StoringController < ActionView::TestCase::TestController
  include PublicActivity::StoreController
  include ActionController::Testing::ClassMethods
end

class TestStoreController < MiniTest::Unit::TestCase
  def test_storing_controller
    controller = StoringController.new
    PublicActivity.set_controller(controller)
    assert_equal(Thread.current[:controller], controller)
    assert_equal(PublicActivity.get_controller, controller)
  end

  def test_extending_controller
    controller = StoringController.new
    assert_includes controller._process_action_callbacks.select {|c| c.kind == :before}.map(&:filter), :store_controller_for_public_activity
    controller.instance_eval { store_controller_for_public_activity }
    assert_equal Thread.current[:controller], controller
  end
end
