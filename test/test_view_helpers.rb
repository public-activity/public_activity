require 'test_helper'

describe 'ViewHelpers Rendering' do
  include PublicActivity::ViewHelpers

  # is this a proper test?
  it 'provides render_activity helper' do
    activity = mock('activity')
    activity.expects(:render).with(self, {})
    render_activity(activity)
  end
end