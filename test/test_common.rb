require 'test_helper'

class TestCommon < Minitest::Unit::TestCase
  def setup
    @owner     = User.create(:name => "Peter Pan")
    @recipient = User.create(:name => "Bruce Wayne")
    @options   = {:parameters => {:author_name => "Peter",
                  :summary => "Default summary goes here..."},
                  :owner => @owner, :recipient => @recipient}
    @subject = article(@options).new
  end

  def test_enabled_status
    assert_equal PublicActivity.enabled?, article(just_common: true).new.public_activity_enabled?
  end

  def test_priority_parameters
    @subject.save
    assert_equal 'Pan', @subject.create_activity(:test,
                        parameters: {author_name: 'Pan'}).parameters[:author_name]
    assert_equal 'Pan', @subject.create_activity(:test,
                        parameters: {author_name: 'Pan'}).parameters[:author_name]
    assert_nil @subject.create_activity(:test,
                        parameters: {author_name: nil}).parameters[:author_name]
    assert_nil @subject.create_activity(:test,
                        parameters: {author_name: nil}).parameters[:author_name]
  end

  def test_owner_priority
    @subject.save
    assert_equal @recipient, @subject.create_activity(:test, owner: @recipient).owner
    assert_nil @subject.create_activity(:test, owner: nil).owner
  end

  def test_recipient_priority
    @subject.save
    assert_equal @owner, @subject.create_activity(:test, recipient: @owner).recipient
    assert_nil @subject.create_activity(:test, recipient: nil).recipient
  end

  def test_global_fields
    @subject.save
    activity = @subject.activities.last
    assert_equal @options[:parameters], activity.parameters
    assert_equal @owner, activity.owner
  end

  def test_custom_fields
    @subject.save
    @subject.create_activity :with_custom_fields, nonstandard: "Custom allowed"
    assert_equal "Custom allowed", @subject.activities.last.nonstandard
  end

  def test_create_activity_return_value
    @subject.save
    refute_nil @subject.create_activity("some.key")
  end

  def test_owner_in_create_activity
    article = article().new
    article.save
    activity = article.create_activity("some.key", :owner => @owner)
    assert_equal @owner, activity.owner
  end

  def test_resolving_custom_fields
    @subject.name      = "Resolving is great"
    @subject.published = true
    @subject.save
    @subject.create_activity :with_custom_fields, nonstandard: :name
    assert_equal "Resolving is great", @subject.activities.last.nonstandard
    @subject.create_activity :with_custom_fields_2, nonstandard: -> _, model { model.published.to_s }
    assert_equal "true", @subject.activities.last.nonstandard
  end


  def test_prepare_key_custom
    assert_equal "my_custom_key", article.new.prepare_key(:create, :key => :my_custom_key)
  end

  def test_prepare_key_camelcase
    cc = Class.new(article(owner: :user)) do
      def self.name; 'CamelCase' end
    end
    camel_case = cc.new

    assert_equal "camel_case.create", camel_case.prepare_key(:create, {})
  end

  def test_prepare_key_namespaced
    ns = Module.new
    cc = Class.new(article(owner: :user)) do
      def self.name; 'MyNamespace::CamelCase' end
    end
    ns.const_set(:CamelCase, cc)

    assert_equal "my_namespace_camel_case.create", cc.new.prepare_key(:create, {})
  end

  def test_prepare_no_key
    assert_raises PublicActivity::NoKeyProvided do
      @subject.prepare_settings
    end
  end

  def test_resolving_values
    context = mock('context')
    context.expects(:accessor).times(2).returns(5)
    controller = mock('controller')
    controller.expects(:current_user).returns(:cu)
    PublicActivity.set_controller(controller)
    p = -> controller, model {
      assert_equal :cu, controller.current_user
      assert_equal 5, model.accessor
    }
    PublicActivity.resolve_value(context, p)
    PublicActivity.resolve_value(context, :accessor)
  end

end
