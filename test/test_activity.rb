require 'test_helper'

I18n.config.backend.store_translations(:en,
  {:activity => {:test => '%{one} %{two}'}}
)

describe 'PublicActivity::Activity Rendering' do
  describe '#text' do
    subject { PublicActivity::Activity.new(:key => 'activity.test', :parameters => {:one => 1}) }

    specify '#text uses translations' do
      subject.save
      subject.text(:two => 2).must_equal('1 2')
      subject.parameters.must_equal({:one => 1})
    end
  end

  describe '#render' do
    subject do
      PublicActivity::Activity
      .new(:key => 'test', :parameters => {:one => 1}).tap { |s| s.save }
    end

    let(:template_output) { "<strong>1, 2</strong>\n<em>test, #{subject.id}</em>\n" }
    before { @controller.view_paths << File.expand_path('../views', __FILE__) }

    it 'uses view partials when available' do
      PublicActivity.set_controller(Struct.new(:current_user).new('fake'))
      subject.render(self, :two => 2)
      rendered.must_equal template_output + "fake\n"
    end

    it 'uses view partials without controller' do
      PublicActivity.set_controller(nil)
      subject.render(self, :two => 2)
      rendered.must_equal template_output + "\n"
    end

    it 'should fallback to the text view when the partial is missing' do
      PublicActivity.set_controller(nil)
      subject.render(self, two: 2, partial_root: 'missing', fallback: :text)
      rendered.must_equal '1 2'
    end

    it 'provides local variables' do
      PublicActivity.set_controller(nil)
      subject.render(self, locals: {two: 2})
      rendered.chomp.must_equal "2"
    end

    it 'uses translations only when requested' do
      @controller.view_paths.paths.clear
      subject.render(self, two: 2, i18n: true)
      rendered.must_equal '1 2'
    end

    it "pass all params to view context" do
      view_context = mock('ViewContext')
      PublicActivity.set_controller(nil)
      view_context.expects(:render).with() {|params| params[:formats] == ['json']}
      subject.render(view_context, :formats => ['json'])
    end

    describe 'partial' do
      it 'allows custom partials to be used' do
        subject.render(self, two: 2, partial: 'other')
        rendered.must_equal 'hipster-template rendered'
      end

      it 'allows roots to be given' do
        subject.render(self, partial_root: 'custom')
        rendered.must_include "Custom Template Root"
      end

      it 'takes model/key by default' do
        @article = article(just_common: true).create!(name: 'PublicActivity 2.0 has been released')
        activity = @article.create_activity(:posted)

        -> { activity.render(self) }.must_raise ActionView::MissingTemplate

        # error introspection needed
        begin
          activity.render(self)
        rescue ActionView::MissingTemplate => exception
          exception.message.must_include 'public_activity/article/posted'
        end
      end
    end

    describe 'layout' do
      it 'allows custom layouts to be used' do
        subject.render(self, layout: 'activity')
        rendered.must_include "Here be the layouts"

        subject.render(self, layout: :activity)
        rendered.must_include "Here be the layouts"
      end

      it "accepts a custom layout root" do
        subject.render(self, layout: :layout, layout_root: :custom)
        rendered.must_include "Here be the custom layouts"

        subject.render(self, layout: 'activity', layout_root: 'layouts')
        rendered.must_include "Here be the layouts"
      end
    end
  end
end
