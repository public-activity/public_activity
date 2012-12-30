require 'test_helper'

describe PublicActivity::Activist do
  it 'adds owner association' do
    klass = article
    klass.must_respond_to :activist
    klass.activist
    klass.new.must_respond_to :activities
    if ENV["PA_ORM"] == "active_record"
      klass.reflect_on_association(:activities_as_owner).options[:as].must_equal :owner
    elsif ENV["PA_ORM"] == "mongoid"
      klass.reflect_on_association(:activities_as_owner).options[:inverse_of].must_equal :owner
    end

    klass.reflect_on_association(:activities_as_owner).options[:class_name].must_equal "PublicActivity::Activity"
  end
end
