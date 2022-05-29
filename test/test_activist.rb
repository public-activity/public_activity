# frozen_string_literal: true

require 'test_helper'

describe PublicActivity::Activist do
  it 'adds owner association' do
    klass = article
    assert_respond_to klass, :activist
    klass.activist
    assert_respond_to klass.new, :activities

    case ENV['PA_ORM']
    when 'active_record'
      assert_equal klass.reflect_on_association(:activities_as_owner).options[:as], :owner
    when 'mongoid'
      assert_equal klass.reflect_on_association(:activities_as_owner).options[:inverse_of], :owner
    when 'mongo_mapper'
      assert_equal klass.associations[:activities_as_owner].options[:as], :owner
    end

    if ENV['PA_ORM'] == 'mongo_mapper'
      assert_equal klass.associations[:activities_as_owner].options[:class_name], '::PublicActivity::Activity'
    else
      assert_equal klass.reflect_on_association(:activities_as_owner).options[:class_name], '::PublicActivity::Activity'
    end
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
    when :mongo_mapper
      class ActivistUser
        include MongoMapper::Document
        include PublicActivity::Model
        activist

        key :name, String
      end
    end
    owner = ActivistUser.create(name: 'Peter Pan')
    a = article(owner: owner).new
    a.save

    assert_equal owner.activities_as_owner.length, 1
  end
end
