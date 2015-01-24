require 'test_helper'

class TestActivist < Minitest::Unit::TestCase
  def test_owner_association
    klass = article
    assert_respond_to klass, :activist
    klass.activist
    assert_respond_to klass.new, :activities

    assert_equal :owner,
      case ENV["PA_ORM"]
      when "active_record"
        klass.reflect_on_association(:activities_as_owner).options[:as]
      when "mongoid"
        klass.reflect_on_association(:activities_as_owner).options[:inverse_of]
      when "mongo_mapper"
        klass.associations[:activities_as_owner].options[:as]
      end

    assert_equal "::PublicActivity::Activity",
      if ENV["PA_ORM"] == "mongo_mapper"
        klass.associations[:activities_as_owner].options[:class_name]
      else
        klass.reflect_on_association(:activities_as_owner).options[:class_name]
      end
  end

  def test_activities_from_association
    activist_user = case PublicActivity.config.orm
                    when :active_record
                      Class.new(ActiveRecord::Base) do
                        include PublicActivity::Model
                        self.table_name = 'users'
                        activist
                        def self.name; 'ActivistUser' end
                      end
                    when :mongoid
                      Class.new do
                        include Mongoid::Document
                        include PublicActivity::Model
                        activist

                        field :name, type: String

                        def self.name; 'ActivistUser' end
                      end
                    when :mongo_mapper
                      Class.new do
                        include MongoMapper::Document
                        include PublicActivity::Model
                        activist

                        key :name, String

                        def self.name; 'ActivistUser' end
                      end
                    end

    owner = activist_user.create(:name => "Peter Pan")
    a = article(owner: owner).new
    a.save

    assert_equal 1, owner.activities_as_owner.length
  end
end
