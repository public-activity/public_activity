require 'test_helper'

class TestActivityRendering < Minitest::Unit::TestCase
  include ActiveSupport::Testing::SetupAndTeardown
  include ActionView::TestCase::Behavior

  def setup
    @subject = PublicActivity::Activity.new(key: "test", parameters: {one: 1}).tap(&:save)
    @template_output = "<strong>1, 2</strong>\n<em>test, #{@subject.id}</em>\n"
    @controller.view_paths << File.expand_path("../views", __FILE__)
  end

  def test_view_partials
    PublicActivity.set_controller(Struct.new(:current_user).new('fake'))
    @subject.render(self, :two => 2)
    assert_equal @template_output + "fake\n", rendered
  end

  def test_view_partials_without_controller
    PublicActivity.set_controller(nil)
    @subject.render(self, :two => 2)
    assert_equal @template_output + "\n", rendered
  end

  def test_view_partials_fallback
    PublicActivity.set_controller(nil)
    @subject.render(self, two: 2, partial_root: 'missing', fallback: 'default')
    assert_equal "default text here\n", rendered
  end

  def test_locals_propagation
    PublicActivity.set_controller(nil)
    @subject.render(self, locals: {two: 2})
    assert_equal "2", rendered.chomp
  end

  def test_view_context_param_propagation
    view_context = mock('ViewContext')
    PublicActivity.set_controller(nil)
    view_context.expects(:render).with() {|params| params[:formats] == ['json']}
    @subject.render(view_context, :formats => ['json'])
  end

  def test_custom_partials
    @subject.render(self, two: 2, partial: 'other')
    assert_equal "hipster-template rendered", rendered
  end

  def test_partial_root
    @subject.render(self, partial_root: 'custom')
    assert_includes rendered, "Custom Template Root"
  end

  def test_default_path
    @article = article(just_common: true).create!(name: 'PublicActivity 2.0 has been released')
    activity = @article.create_activity(:posted)

    assert_raises ActionView::MissingTemplate do
      activity.render(self)
    end

    # error introspection needed
    begin
      activity.render(self)
    rescue ActionView::MissingTemplate => exception
      assert_includes exception.message, "public_activity/article/posted"
    end
  end

  def test_custom_layouts
    @subject.render(self, layout: 'activity')
    assert_includes rendered, "Here be the layouts"

    @subject.render(self, layout: :activity)
    assert_includes rendered, "Here be the layouts"
  end

  def test_custom_layout_root
    @subject.render(self, layout: :layout, layout_root: :custom)
    assert_includes rendered, "Here be the custom layouts"

    @subject.render(self, layout: 'activity', layout_root: 'layouts')
    assert_includes rendered, "Here be the layouts"
  end
end
