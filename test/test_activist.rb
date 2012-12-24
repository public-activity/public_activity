require 'test_helper'

describe PublicActivity::Activist do
  it 'adds owner association' do
    klass = article
    klass.must_respond_to :activist
    klass.activist
    assert_respond_to klass, :activist
    assert_respond_to klass.new, :activities
    assert_equal :owner, klass.reflect_on_association(:activities_as_owner).options[:as]
    assert_equal "PublicActivity::Activity", klass.reflect_on_association(:activities_as_owner).options[:class_name]
  end
end
