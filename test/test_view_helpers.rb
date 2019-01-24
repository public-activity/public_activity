# frozen_string_literal: true

require 'test_helper'

describe 'ViewHelpers Rendering' do
  include PublicActivity::ViewHelpers

  # is this a proper test?
  it 'provides render_activity helper' do
    activity = mock('activity')
    activity.stubs(:is_a?).with(PublicActivity::Activity).returns(true)
    activity.expects(:render).with(self, {})
    render_activity(activity)
  end

  it 'handles multiple activities' do
    activity = mock('activity')
    activity.expects(:render).with(self, {})
    render_activities([activity])
  end

  it 'flushes content_for between partials renderes' do
    @view_flow = mock('view_flow')
    @view_flow.expects(:set).twice.with('name', ActiveSupport::SafeBuffer.new)

    single_content_for('name', 'content')
    @name.must_equal 'name'
    @content.must_equal 'content'
    single_content_for('name', 'content2')
    @name.must_equal 'name'
    @content.must_equal 'content2'
  end

  def content_for(name, content, &block)
    @name = name
    @content = content
  end
end
