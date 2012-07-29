require 'test_helper'

class TestViewHelpers < ActionView::TestCase
  include PublicActivity::ViewHelpers

  # is this a proper test?
  def test_helper_render_activity
    activity = mock('activity')
    activity.expects(:render).with(self, {})
    render_activity(activity)
  end
end