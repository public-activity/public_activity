# frozen_string_literal: true

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
      rendered.must_equal template_output + "fake\n"
    end

    it 'uses requested partial'

    it 'uses view partials without controller' do
      PublicActivity.set_controller(nil)
      subject.render(self, :two => 2)
      rendered.must_equal template_output + "\n"
    end

    it 'provides local variables' do
      PublicActivity.set_controller(nil)
      subject.render(self, locals: {two: 2})
      rendered.chomp.must_equal "2"
    end

    it 'uses translations only when requested' do
      I18n.config.backend.store_translations(:en,
        {:activity => {:test => '%{one} %{two}'}}
      )
      @controller.view_paths.paths.clear
      subject.render(self, two: 2, display: :i18n)
      rendered.must_equal '1 2'
    end

    it "pass all params to view context" do
      view_context = mock('ViewContext')
      PublicActivity.set_controller(nil)
      view_context.expects(:render).with() {|params| params[:formats] == ['json']}
      subject.render(view_context, :formats => ['json'])
    end

    it "uses specified layout" do
      PublicActivity.set_controller(nil)
      subject.render(self, :layout => "activity")
      rendered.must_include "Here be the layouts"

      subject.render(self, :layout => "layouts/activity")
      rendered.must_include "Here be the layouts"

      subject.render(self, :layout => :activity)
      rendered.must_include "Here be the layouts"
    end

    it "accepts a custom layout root" do
      subject.render(self, :layout => :layout, :layout_root => "custom")
      rendered.must_include "Here be the custom layouts"
    end
    it "accepts an absolute layout path" do
      subject.render(self, :layout => '/custom/layout')
      rendered.must_include "Here be the custom layouts"
    end
    it "accepts a template root" do
      subject.render(self, :root => "custom")
      rendered.must_include "Custom Template Root"
    end
  end
end
