require 'test_helper'

describe PublicActivity::Activist do
  it 'adds owner association' do
    klass = article
    klass.must_respond_to :activist
    klass.activist
    klass.new.must_respond_to :activities
    if ENV["PA_ORM"] == "active_record"
      klass.reflect_on_association(:activities_as_owner).options[:as].must_equal :owner
      klass.reflect_on_association(:activities_as_owner).options[:include].must_equal [:trackable, :owner]
    elsif ENV["PA_ORM"] == "mongoid"
      klass.reflect_on_association(:activities_as_owner).options[:inverse_of].must_equal :owner
    end

    klass.reflect_on_association(:activities_as_owner).options[:class_name].must_equal "::PublicActivity::Activity"
  end

  it 'returns activities from association' do
    case PublicActivity::Config.orm
      when :active_record
        class ActivistUser < ActiveRecord::Base
          include PublicActivity::Model
          self.table_name = 'users'
          activist
        end
      when :mongoid
        class ActivistUser
          include Mongoid::Document
          include PublicActivity::Model
          activist

          field :name, type: String
      end
    end
    owner = ActivistUser.create(:name => "Peter Pan")
    a = article(owner: owner).new
    a.save

    owner.activities_as_owner.length.must_equal 1
  end
end
