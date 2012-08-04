require 'test_helper'

class TestActivist < MiniTest::Unit::TestCase
  def test_adding_association
    klass = article
    klass.activist
    assert_respond_to klass, :activist
    assert_respond_to klass.new, :activities
    assert_equal :owner, klass.reflect_on_association(:activities).options[:as]
    assert_equal "PublicActivity::Activity", klass.reflect_on_association(:activities).options[:class_name]
  end
end
