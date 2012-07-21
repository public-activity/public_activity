require 'test_helper'

class TestTracking < Test::Unit::TestCase
  def test_creating_activity
    Article.tracked
    @article = Article.new
    @article.stubs(:get_hook).with('create').returns(nil)
    @article.expects(:activity_on_create)
    @article.save
  end
end
