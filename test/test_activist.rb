require 'test_helper'

describe PublicActivity::Activist do
  it 'adds owner association' do
    klass = article
    klass.must_respond_to :activist
    klass.activist
    klass.new.must_respond_to :activities
    klass.reflect_on_association(:activities_as_owner).options[:as].must_equal :owner
    klass.reflect_on_association(:activities_as_owner).options[:class_name].must_equal "PublicActivity::Activity"
  end
end
