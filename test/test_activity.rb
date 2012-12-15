require 'test_helper'

describe 'PublicActivity::Activity Rendering' do
  describe '#text' do
    subject { PublicActivity::Activity.new(:key => 'activity.test', :parameters => {:one => 1}) }

    specify '#text uses translations' do
      subject.save
      I18n.config.backend.store_translations(:en,
        {:activity => {:test => '%{one} %{two}'}}
      )
      subject.text(:two => 2).must_equal('1 2')
      subject.parameters.must_equal({:one => 1})
    end
  end

  describe '#render' do
    subject do
      s = PublicActivity::Activity.new(:key => 'activity.test', :parameters => {:one => 1})
      s.save && s
    end

    let(:template_output) { "<strong>1, 2</strong>\n<em>activity.test, #{subject.id}</em>\n" }
    before { @controller.view_paths << File.expand_path('../views', __FILE__) }

    it 'uses view partials when available' do
      PublicActivity.set_controller(Struct.new(:current_user).new('fake'))
      subject.render(self, :two => 2)
      rendered.must_equal template_output + 'fake'
    end

    it 'uses view partials without controller' do
      PublicActivity.set_controller(nil)
      subject.render(self, :two => 2)
      rendered.must_equal template_output
    end

    it 'uses translations with no view partials available' do
      I18n.config.backend.store_translations(:en,
        {:activity => {:test => '%{one} %{two}'}}
      )
      @controller.view_paths.paths.clear
      subject.render(self, :two => 2)
      rendered.must_equal '1 2'
    end
  end
end