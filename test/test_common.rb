# frozen_string_literal: true

require 'test_helper'

describe PublicActivity::Common do
  before do
    @owner     = User.create(:name => "Peter Pan")
    @recipient = User.create(:name => "Bruce Wayne")
    @options   = {:params => {:author_name => "Peter",
                  :summary => "Default summary goes here..."},
                  :owner => @owner, :recipient => @recipient}
  end
  subject { article(@options).new }

  it 'prioritizes parameters passed to #create_activity' do
    subject.save
    subject.create_activity(:test, params: {author_name: 'Pan'}).parameters[:author_name].must_equal 'Pan'
    subject.create_activity(:test, parameters: {author_name: 'Pan'}).parameters[:author_name].must_equal 'Pan'
    subject.create_activity(:test, params: {author_name: nil}).parameters[:author_name].must_be_nil
    subject.create_activity(:test, parameters: {author_name: nil}).parameters[:author_name].must_be_nil
  end

  it 'prioritizes owner passed to #create_activity' do
    subject.save
    subject.create_activity(:test, owner: @recipient).owner.must_equal @recipient
    subject.create_activity(:test, owner: nil).owner.must_be_nil
  end

  it 'prioritizes recipient passed to #create_activity' do
    subject.save
    subject.create_activity(:test, recipient: @owner).recipient.must_equal @owner
    subject.create_activity(:test, recipient: nil).recipient.must_be_nil
  end

  it 'uses global fields' do
    subject.save
    activity = subject.activities.last
    activity.parameters.must_equal @options[:params]
    activity.owner.must_equal @owner
  end

  it 'allows custom fields' do
    subject.save
    subject.create_activity :with_custom_fields, nonstandard: "Custom allowed"
    subject.activities.last.nonstandard.must_equal "Custom allowed"
  end

  it '#create_activity returns a new activity object' do
    subject.save
    subject.create_activity("some.key").wont_be_nil
  end

  it '#create_activity! returns a new activity object' do
    subject.save
    activity = subject.create_activity!("some.key")
    assert activity.persisted?
    assert_equal 'article.some.key', activity.key
  end

  it 'update action should not create activity on save unless model changed' do
    subject.save
    before_count = subject.activities.count
    subject.save
    subject.save
    after_count = subject.activities.count
    before_count.must_equal after_count
  end


  it 'allows passing owner through #create_activity' do
    article = article().new
    article.save
    activity = article.create_activity("some.key", :owner => @owner)
    activity.owner.must_equal @owner
  end

  it 'allows resolving custom fields' do
    subject.name      = "Resolving is great"
    subject.published = true
    subject.save
    subject.create_activity :with_custom_fields, nonstandard: :name
    subject.activities.last.nonstandard.must_equal "Resolving is great"
    subject.create_activity :with_custom_fields_2, nonstandard: proc {|_, model| model.published.to_s}
    subject.activities.last.nonstandard.must_equal "true"
  end

  it 'inherits instance parameters' do
    subject.activity :params => {:author_name => "Michael"}
    subject.save
    activity = subject.activities.last

    activity.parameters[:author_name].must_equal "Michael"
  end

  it 'accepts instance recipient' do
    subject.activity :recipient => @recipient
    subject.save
    subject.activities.last.recipient.must_equal @recipient
  end

  it 'accepts instance owner' do
    subject.activity :owner => @owner
    subject.save
    subject.activities.last.owner.must_equal @owner
  end

  it 'accepts owner as a symbol' do
    klass = article(:owner => :user)
    @article = klass.new(:user => @owner)
    @article.save
    activity = @article.activities.last

    activity.owner.must_equal @owner
  end

  it 'reports PublicActivity::Activity as the base class' do
    if ENV["PA_ORM"] == "active_record" # Only relevant for ActiveRecord
      subject.save
      subject.activities.last.class.base_class.must_equal PublicActivity::Activity
    end
  end

  describe '#prepare_key' do
    describe 'for class#activity_key method' do
      before do
        @article = article(:owner => :user).new(:user => @owner)
      end

      it 'assigns key to value of activity_key if set' do
        def @article.activity_key; "my_custom_key" end

        @article.prepare_key(:create, {}).must_equal "my_custom_key"
      end

      it 'assigns key based on class name as fallback' do
        def @article.activity_key; nil end

        @article.prepare_key(:create).must_equal "article.create"
      end

      it 'assigns key value from options hash' do
        @article.prepare_key(:create, :key => :my_custom_key).must_equal "my_custom_key"
      end
    end

    describe 'for camel cased classes' do
      before do
        class CamelCase < article(:owner => :user)
          def self.name; 'CamelCase' end
        end
        @camel_case = CamelCase.new
      end

      it 'assigns generates key from class name' do
        @camel_case.prepare_key(:create, {}).must_equal "camel_case.create"
      end
    end

    describe 'for namespaced classes' do
      before do
        module ::MyNamespace;
          class CamelCase < article(:owner => :user)
            def self.name; 'MyNamespace::CamelCase' end
          end
        end
        @namespaced_camel_case = MyNamespace::CamelCase.new
      end

      it 'assigns key value from options hash' do
        @namespaced_camel_case.prepare_key(:create, {}).must_equal "my_namespace_camel_case.create"
      end
    end
  end

  # no key implicated or given
  specify { ->{subject.prepare_settings}.must_raise PublicActivity::NoKeyProvided }

  describe 'resolving values' do
    it 'allows procs with models and controllers' do
      context = mock('context')
      context.expects(:accessor).times(2).returns(5)
      controller = mock('controller')
      controller.expects(:current_user).returns(:cu)
      PublicActivity.set_controller(controller)
      p = proc {|c, m|
        assert_equal :cu, c.current_user
        assert_equal 5, m.accessor
      }
      PublicActivity.resolve_value(context, p)
      PublicActivity.resolve_value(context, :accessor)
    end
  end

end
