require 'test_helper'

class TestCommon < MiniTest::Unit::TestCase

  def test_default_settings
    owner = User.create(:name => "Peter Pan")
    options = {:params => {:author_name => "Peter"}, :owner => owner}
    klass = article(options)
    article = klass.new
    article.save
    activity = article.activities.last
    assert_equal activity.parameters[:author_name], options[:params][:author_name]
    assert_equal activity.owner.id, owner.id
  end

  def test_params_inheriting
    options = {:params => {:author_name => "Peter", :summary => "Default summary goes here..."}}
    klass = article(options)
    article = klass.new
    article.activity :params => {:author_name => "Michael"}
    article.save
    activity = article.activities.last

    assert_equal activity.parameters[:author_name], "Michael"
    assert_equal activity.parameters[:summary], options[:params][:summary]
  end
end