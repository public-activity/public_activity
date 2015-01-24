require 'test_helper'

class TestTracked < Minitest::Unit::TestCase
  def setup
    @article = article
  end

  def test_skipping_crud_actions
    case PublicActivity.config.orm
    when :mongoid
      art = Class.new do
        include Mongoid::Document
        include Mongoid::Timestamps
        include PublicActivity::Model

        belongs_to :user

        field :name, type: String
        field :published, type: Boolean
        tracked :skip_defaults => true
      end
    when :mongo_mapper
      art = Class.new do
        include MongoMapper::Document
        include PublicActivity::Model

        belongs_to :user

        key :name, String
        key :published, Boolean
        tracked :skip_defaults => true

        timestamps!
      end
    when :active_record
      art = article(:skip_defaults => true)
    end

    assert_includes art, PublicActivity::Common
    refute_includes art, PublicActivity::Creation
    refute_includes art, PublicActivity::Update
    refute_includes art, PublicActivity::Destruction
  end

  def test_default_options
    assert_includes @article, PublicActivity::Common
    assert_includes @article, PublicActivity::Creation
    assert_includes @article, PublicActivity::Update
    assert_includes @article, PublicActivity::Destruction

    refute_empty @article._create_callbacks.select { |c| c.kind == :after }
    refute_empty @article._update_callbacks.select { |c| c.kind == :after }
    refute_empty @article._destroy_callbacks.select { |c| c.kind == :before }
  end

  def test_except_option
    case PublicActivity.config.orm
    when :mongoid
      art = Class.new do
        include Mongoid::Document
        include Mongoid::Timestamps
        include PublicActivity::Model

        belongs_to :user

        field :name, type: String
        field :published, type: Boolean
        tracked :except => [:create]
      end
    when :mongo_mapper
      art = Class.new do
        include MongoMapper::Document
        include PublicActivity::Model

        belongs_to :user

        key :name, String
        key :published, Boolean
        tracked :except => [:create]

        timestamps!
      end
    when :active_record
      art = article(:except => [:create])
    end

    refute_includes art, PublicActivity::Creation
    assert_includes art, PublicActivity::Update
    assert_includes art, PublicActivity::Destruction
  end

  def test_accepts_option
    case PublicActivity.config.orm
    when :mongoid
      art = Class.new do
        include Mongoid::Document
        include Mongoid::Timestamps
        include PublicActivity::Model

        belongs_to :user

        field :name, type: String
        field :published, type: Boolean

        tracked :only => [:create, :update]
      end
    when :mongo_mapper
      art = Class.new do
        include MongoMapper::Document
        include PublicActivity::Model

        belongs_to :user

        key :name, String
        key :published, Boolean

        tracked :only => [:create, :update]
      end
    when :active_record
      art = article({:only => [:create, :update]})
    end

    assert_includes art, PublicActivity::Creation
    refute_includes art, PublicActivity::Destruction
    assert_includes art, PublicActivity::Update
  end

  def test_owner_option
    owner = mock('owner')
    @article.tracked(:owner => owner)
    assert_equal owner, @article.activity_owner_global
  end

  def test_parameters_option
    params = {:a => 1}
    @article.tracked(:parameters => params)
    assert_equal params, @article.activity_parameters_global
  end

  def test_on_option
    on = {:a => lambda{}, :b => proc {}}
    @article.tracked(:on => on)
    assert_equal on, @article.activity_hooks
  end
end
