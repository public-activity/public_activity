require 'test_helper'

class TestViewHelpers < Minitest::Unit::TestCase
  include PublicActivity::ViewHelpers

  def test_render_activity_helper
    activity = mock('activity')
    activity.stubs(:is_a?).with(PublicActivity::Activity).returns(true)
    activity.expects(:render).with(self, {})
    render_activity(activity)
  end

  def test_render_multiple_activities
    activity = mock('activity')
    activity.expects(:render).with(self, {})
    render_activities([activity])
  end
end
