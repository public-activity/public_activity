require 'test_helper'

class TestCommon < MiniTest::Unit::TestCase

  def test_default_settings
    owner = User.create(:name => "Peter Pan")
    options = {:params => {:author_name => "Peter"}, :owner => owner}
    klass = article(options)
    article = klass.new
    article.save
    activity = article.activities.last
    assert_equal options[:params][:author_name], activity.parameters[:author_name]
    assert_equal owner.id, activity.owner.id
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
end