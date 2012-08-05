require 'test_helper'

class TestActivity < ActionView::TestCase
  def test_rendering
    @activity = PublicActivity::Activity.new(:key => 'activity.test')
    @activity.parameters = {:one => 1}
    @activity.save
    I18n.config.backend.store_translations(:en,
      {:activity => {:test => '%{one} %{two}'}}
    )
    assert_equal '1 2', @activity.text(:two => 2)
    assert_equal({:one => 1}, @activity.parameters,
      'Activity#text should not change instance parameters'
    )

    # #render
    PublicActivity.set_controller(Struct.new(:current_user).new('fake'))
    @controller.view_paths << File.expand_path('../views', __FILE__)
    @activity.render(self, :two => 2)
    template_output_safe = "<strong>1, 2</strong>\n<em>activity.test, 1</em>\n"
    assert_equal template_output_safe + 'fake', rendered

    # test without controller provided for p_a
    rendered.clear && PublicActivity.class_variable_set(:@@controllers, {})
    @activity.render(self, :two => 2)
    assert_equal rendered, template_output_safe

    # #text into buffer
    rendered.clear && @controller.view_paths.paths.clear
    @activity.render(self, :two => 2)
    assert_equal '1 2', rendered
  end
end