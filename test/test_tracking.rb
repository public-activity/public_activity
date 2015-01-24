require 'test_helper'

class TestTracking < Minitest::Unit::TestCase
  def test_tracked_activist
    klass = case PublicActivity.config.orm
            when :mongoid
              Class.new do
                include Mongoid::Document
                include Mongoid::Timestamps
                include PublicActivity::Model

                belongs_to :user

                def self.name; "ActivistAndTrackedArticle" end

                field :name, type: String
                field :published, type: Boolean
                tracked
                activist
              end
            when :mongo_mapper
              Class.new do
                include MongoMapper::Document
                include PublicActivity::Model

                belongs_to :user

                def self.name; "ActivistAndTrackedArticle" end

                key :name, String
                key :published, Boolean
                tracked
                activist
                timestamps!
              end
            when :active_record
              Class.new(ActiveRecord::Base) do
                self.table_name = 'articles'
                include PublicActivity::Model
                tracked
                activist

                def self.name; "ActivistAndTrackedArticle" end

                if ::ActiveRecord::VERSION::MAJOR < 4
                  attr_accessible :name, :published, :user
                end
                belongs_to :user
              end
            end

    art = klass.new
    art.save
    assert_equal art.id, art.activities.last.trackable_id
    assert_nil art.activities.last.owner_id
  end

  def test_global_custom_fields
    a = article(nonstandard: :name).new(name: "Symbol resolved")
    a.save
    assert_equal "Symbol resolved", a.activities.last.nonstandard

    a = article(nonstandard: -> _, model { model.name }).new(name: "Proc resolved")
    a.save
    assert_equal "Proc resolved", a.activities.last.nonstandard
  end

  def test_refuse_global_key
    a = article(key: 'asd').new
    PublicActivity.without_tracking { a.save }
    assert_raises PublicActivity::NoKeyProvided do
      a.create_activity
    end
    assert a.activities.count.zero?
  end

  # regression test
  def test_not_changing_bloabl_custom_fields
    a = article(nonstandard: "global").new
    a.save
    a.create_activity key: "asd", nonstandard: "instance"
    assert_equal({nonstandard: "global"}, a.class.activity_custom_fields_global)
  end

  def test_class_disable
    activity_count_before = PublicActivity::Activity.count

    klass = article
    klass.public_activity_off
    @article = klass.new
    @article.save
    assert_equal activity_count_before, PublicActivity::Activity.count

    klass.public_activity_on
    @article.save
    assert_operator PublicActivity::Activity.count, :>, activity_count_before
  end
end
