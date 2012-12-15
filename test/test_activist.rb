require 'test_helper'

describe PublicActivity::Activist do
  it 'adds owner association' do
    klass = article
    klass.must_respond_to :activist
    klass.activist
    klass.new.must_respond_to :activities
    klass.reflect_on_association(:activities).options[:as].must_equal :owner
    klass.reflect_on_association(:activities).options[:class_name].must_equal "PublicActivity::Activity"
  end
end
