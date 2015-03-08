require 'test_helper'

class TestActivityHooks < Minitest::Unit::TestCase
  def setup
    @hook = -> {}
    @article = article
    @article.activity_hooks = {test: @hook}
  end

  def test_getter_sym
    assert_same @hook, @article.get_hook(:test)
  end

  def test_getter_string
    assert_same @hook, @article.get_hook("test")
  end

  def test_getter_nonexistent
    assert_nil @article.get_hook(:nonexistent)
  end

  def test_hooks_deciding_about_creation_of_activities
    @article.tracked
    @article = @article.new(:name => "Some Name")
    PublicActivity.set_controller(mock("controller"))
    pf = -> model, controller {
      assert_same PublicActivity.get_controller, controller
      assert_equal "Some Name", model.name
      false
    }
    pt = -> model, controller {
      assert_same PublicActivity.get_controller, controller
      assert_equal "Other Name", model.name
      true # this will save the activity with *.update key
    }
    @article.class.activity_hooks = {:create => pf, :update => pt, :destroy => pt}

    assert_empty @article.activities.to_a
    @article.save # create
    @article.name = "Other Name"
    @article.save # update
    @article.destroy # destroy

    assert_equal 2, @article.activities.count
    assert_equal "article.update", @article.activities.first.key
  end
end
