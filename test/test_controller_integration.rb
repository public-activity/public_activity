# frozen_string_literal: true

require 'test_helper'

class StoringController < ActionView::TestCase::TestController
  include PublicActivity::StoreController
  include ActionController::Testing
end

describe PublicActivity::StoreController do
  it 'stores controller' do
    controller = StoringController.new
    PublicActivity.set_controller(controller)
    assert_same controller, Thread.current[:public_activity_controller]
    assert_same controller, PublicActivity.get_controller
  end

  it 'stores controller with a filter in controller' do
    controller = StoringController.new

    callbacks = controller._process_action_callbacks.select { |c| c.kind == :around }.map(&:filter)
    assert_includes(callbacks, :store_controller_for_public_activity)

    public_activity_controller =
      controller.instance_eval do
        store_controller_for_public_activity do
          PublicActivity.get_controller
        end
      end

    assert_equal controller, public_activity_controller
  end

  it 'stores controller in a threadsafe way' do
    PublicActivity.set_controller(1)
    assert_equal PublicActivity.get_controller, 1

    Thread.new do
      PublicActivity.set_controller(2)
      assert_equal 2, PublicActivity.get_controller
      PublicActivity.set_controller(nil)
    end

    assert_equal PublicActivity.get_controller, 1

    PublicActivity.set_controller(nil)
  end
end
