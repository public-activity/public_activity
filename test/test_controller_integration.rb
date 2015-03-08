require 'test_helper'

class StoringController < ActionView::TestCase::TestController
  include PublicActivity::StoreController
  include ActionController::Testing::ClassMethods
end

class TestStoreController < Minitest::Unit::TestCase
  def test_storing_controller
    controller = StoringController.new
    PublicActivity.set_controller(controller)
    assert_equal Thread.current[:public_activity_controller], controller
    assert_equal PublicActivity.get_controller, controller
  end

  def test_store_controller_filter
    controller = StoringController.new

    assert_includes controller._process_action_callbacks
                    .select {|c| c.kind == :before }
                    .map(&:filter),
                    :store_controller_for_public_activity

    controller.instance_eval { store_controller_for_public_activity }
    assert_equal Thread.current[:public_activity_controller], controller
  end

  def test_thread_safety
    PublicActivity.set_controller(1)
    assert_equal 1, PublicActivity.get_controller

    a = Thread.new {
      PublicActivity.set_controller(2)
      assert_equal 2, PublicActivity.get_controller
    }

    a.join
    assert_equal 1, PublicActivity.get_controller
  end
end
