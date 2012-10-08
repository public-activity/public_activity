require 'test_helper'

class TestCommon < MiniTest::Unit::TestCase
  
  def test_default_settings
    owner = User.create(:name => "Peter Pan")
    options = {:params => {:author_name => "Peter", :article_name => :name, :short_article_name => proc {|c, m| m.name[0..3] + "..."}}, :owner => owner}
    klass = article(options)
    article = klass.new(:name => "Some article")
    article.save
    activity = article.activities.last
    assert_equal options[:params][:author_name], activity.parameters[:author_name]
    assert_equal owner.id, activity.owner.id
    assert_equal "Some article", activity.parameters[:article_name]
    assert_equal "Some...", activity.parameters[:short_article_name]
  end

  def test_params_inheriting
    options = {:params => {:author_name => "Peter", :summary => "Default summary goes here..."}}
    klass = article(options)
    article = klass.new
    article.activity :params => {:author_name => "Michael"}
    article.save
    activity = article.activities.last

    assert_equal "Michael", activity.parameters[:author_name]
    assert_equal options[:params][:summary], activity.parameters[:summary]
  end

  def test_owner_as_exact_value
    owner = User.create(:name => "Bruce Wayne")
    klass = article(:owner => owner)
    article = klass.new
    article.save
    activity = article.activities.last

    assert_equal owner, activity.owner
  end

  def test_owner_as_a_proc
    owner = User.create(:name => "Max Payne")
    klass = article(:owner => proc { User.where(:name => "Max Payne").first })
    article = klass.new
    article.save
    activity = article.activities.last

    assert_equal owner, activity.owner
  end

  def test_owner_as_a_symbol
    owner = User.create(:name => "Teddy Gammell")
    klass = article(:owner => :user)
    article = klass.new(:user => owner)
    article.save
    activity = article.activities.last

    assert_equal owner, activity.owner
  end

  # Creating custom activities

  def test_creating_custom_activities
    user = User.create(:name => "Phil Dunphy")
    @article = article(:skip_defaults => true).new(:user => user)
    @article.activity :owner => :user
    @article.save
    @article.create_activity :some_action, :owner => :user, :recipient => user,
      :params => {:a => :user}
    assert_operator @article.activities.count, :>=, 1
    assert_equal 'article.some_action', @article.activities.last.key
    assert_equal user, @article.activities.last.owner
    assert_equal user, @article.activities.last.recipient
    assert_equal({:a => user}, @article.activities.last.parameters)
  end

  def test_throwing_on_no_key_creating_custom_activities
    @article = article(:skip_defaults => true).new
    assert_raises PublicActivity::NoKeyProvided do
      @article.create_activity
    end
  end

  # Smart values
  def test_resolving_values
    context = mock('context')
    context.expects(:accessor).times(2).returns(5)
    controller = mock('controller')
    controller.expects(:current_user).returns(:cu)
    PublicActivity.set_controller(controller)
    p = proc {|controller, model|
      assert_equal :cu, controller.current_user
      assert_equal 5, model.accessor
    }
    PublicActivity.resolve_value(context, p)
    PublicActivity.resolve_value(context, :accessor)
  end

end