# frozen_string_literal: true

require 'test_helper'

describe PublicActivity::Tracked do
  describe 'defining instance options' do
    subject { article.new }
    let :options do
      {
        key: 'key',
        params: { a: 1 },
        owner: User.create,
        recipient: User.create
      }
    end
    before(:each) { subject.activity(options) }
    let(:activity) { subject.save; subject.activities.last }

    specify { assert_same subject.activity_key, options[:key] }
    specify { assert_equal activity.key, options[:key] }

    specify { assert_same subject.activity_owner, options[:owner] }
    specify { assert_equal activity.owner, options[:owner] }

    specify { assert_same subject.activity_params, options[:params] }
    specify { assert_equal activity.parameters, options[:params] }

    specify { assert_same subject.activity_recipient, options[:recipient] }
    specify { assert_equal activity.recipient, options[:recipient] }
  end

  it 'can be tracked and be an activist at the same time' do
    case PublicActivity.config.orm
    when :mongoid
      class ActivistAndTrackedArticle
        include Mongoid::Document
        include Mongoid::Timestamps
        include PublicActivity::Model

        if ::Mongoid::VERSION.split('.')[0].to_i >= 7
          belongs_to :user, optional: true
        else
          belongs_to :user
        end

        field :name, type: String
        field :published, type: Boolean
        tracked
        activist
      end
    when :mongo_mapper
      class ActivistAndTrackedArticle
        include MongoMapper::Document
        include PublicActivity::Model

        belongs_to :user

        key :name, String
        key :published, Boolean
        tracked
        activist
        timestamps!
      end
    when :active_record
      class ActivistAndTrackedArticle < ActiveRecord::Base
        self.table_name = 'articles'
        include PublicActivity::Model
        tracked
        activist

        belongs_to :user
      end
    end

    art = ActivistAndTrackedArticle.new
    art.save
    assert_equal art.activities.last.trackable_id, art.id
    assert_nil art.activities.last.owner_id
  end

  describe 'custom fields' do
    describe 'global' do
      it 'should resolve symbols' do
        a = article(nonstandard: :name).new(name: 'Symbol resolved')
        a.save
        assert_equal a.activities.last.nonstandard, 'Symbol resolved'
      end

      it 'should resolve procs' do
        a = article(nonstandard: proc { |_, model| model.name }).new(name: 'Proc resolved')
        a.save
        assert_equal a.activities.last.nonstandard, 'Proc resolved'
      end
    end

    describe 'instance' do
      it 'should resolve symbols' do
        a = article.new(name: 'Symbol resolved')
        a.activity nonstandard: :name
        a.save
        assert_equal a.activities.last.nonstandard, 'Symbol resolved'
      end

      it 'should resolve procs' do
        a = article.new(name: 'Proc resolved')
        a.activity nonstandard: proc { |_, model| model.name }
        a.save
        assert_equal a.activities.last.nonstandard, 'Proc resolved'
      end
    end
  end

  it 'should reset instance options on successful create_activity' do
    a = article.new
    a.activity key: 'test', params: { test: 1 }
    a.save
    assert_equal a.activities.count, 1
    assert_raises(PublicActivity::NoKeyProvided) { a.create_activity }
    assert_empty a.activity_params
    a.activity key: 'asd'
    a.create_activity
    assert_raises(PublicActivity::NoKeyProvided) { a.create_activity }
  end

  it 'should not accept global key option' do
    # this example tests the lack of presence of sth that should not be here
    a = article(key: 'asd').new
    a.save
    assert_raises(PublicActivity::NoKeyProvided) { a.create_activity }
    assert_equal a.activities.count, 1
  end

  it 'should not change global custom fields' do
    a = article(nonstandard: 'global').new
    a.activity nonstandard: 'instance'
    a.save
    assert_equal a.class.activity_custom_fields_global, nonstandard: 'global'
  end

  describe 'disabling functionality' do
    it 'allows for global disable' do
      PublicActivity.enabled = false
      activity_count_before = PublicActivity::Activity.count

      @article = article.new
      @article.save
      assert_equal PublicActivity::Activity.count, activity_count_before

      PublicActivity.enabled = true
    end

    it 'allows for class-wide disable' do
      activity_count_before = PublicActivity::Activity.count

      klass = article
      klass.public_activity_off
      @article = klass.new
      @article.save
      assert_equal PublicActivity::Activity.count, activity_count_before

      klass.public_activity_on
      @article.name = 'Changed Article'
      @article.save
      assert(PublicActivity::Activity.count > activity_count_before)
    end
  end

  describe '#tracked' do
    subject { article(options) }
    let(:options) { {} }

    it 'allows skipping the tracking on CRUD actions' do
      art =
        case PublicActivity.config.orm
        when :mongoid
          Class.new do
            include Mongoid::Document
            include Mongoid::Timestamps
            include PublicActivity::Model

            belongs_to :user

            field :name, type: String
            field :published, type: Boolean
            tracked skip_defaults: true
          end
        when :mongo_mapper
          Class.new do
            include MongoMapper::Document
            include PublicActivity::Model

            belongs_to :user

            key :name, String
            key :published, Boolean
            tracked skip_defaults: true

            timestamps!
          end
        when :active_record
          article(skip_defaults: true)
        end

      assert_includes art, PublicActivity::Common
      refute_includes art, PublicActivity::Creation
      refute_includes art, PublicActivity::Update
      refute_includes art, PublicActivity::Destruction
    end

    describe 'default options' do
      subject { article }

      specify { assert_includes subject, PublicActivity::Creation }
      specify { assert_includes subject, PublicActivity::Destruction }
      specify { assert_includes subject, PublicActivity::Update }

      specify do
        callbacks = subject._create_callbacks.select do |c|
          c.kind.eql?(:after) && c.filter == :activity_on_create
        end

        refute_empty callbacks
      end

      specify do
        callbacks = subject._update_callbacks.select do |c|
          c.kind.eql?(:after) && c.filter == :activity_on_update
        end

        refute_empty callbacks
      end

      specify do
        callbacks = subject._destroy_callbacks.select do |c|
          c.kind.eql?(:before) && c.filter == :activity_on_destroy
        end

        refute_empty callbacks
      end
    end

    it 'accepts :except option' do
      art =
        case PublicActivity.config.orm
        when :mongoid
          Class.new do
            include Mongoid::Document
            include Mongoid::Timestamps
            include PublicActivity::Model

            belongs_to :user

            field :name, type: String
            field :published, type: Boolean
            tracked except: [:create]
          end
        when :mongo_mapper
          Class.new do
            include MongoMapper::Document
            include PublicActivity::Model

            belongs_to :user

            key :name, String
            key :published, Boolean
            tracked except: [:create]

            timestamps!
          end
        when :active_record
          article(except: [:create])
        end

      refute_includes art, PublicActivity::Creation
      assert_includes art, PublicActivity::Update
      assert_includes art, PublicActivity::Destruction
    end

    it 'accepts :only option' do
      art =
        case PublicActivity.config.orm
        when :mongoid
          Class.new do
            include Mongoid::Document
            include Mongoid::Timestamps
            include PublicActivity::Model

            belongs_to :user

            field :name, type: String
            field :published, type: Boolean

            tracked only: %i[create update]
          end
        when :mongo_mapper
          Class.new do
            include MongoMapper::Document
            include PublicActivity::Model

            belongs_to :user

            key :name, String
            key :published, Boolean

            tracked only: %i[create update]
          end
        when :active_record
          article(only: %I[create update])
        end

      assert_includes art, PublicActivity::Creation
      refute_includes art, PublicActivity::Destruction
      assert_includes art, PublicActivity::Update
    end

    it 'accepts :owner option' do
      owner = mock('owner')
      subject.tracked(owner: owner)
      assert_equal subject.activity_owner_global, owner
    end

    it 'accepts :params option' do
      params = { a: 1 }
      subject.tracked(params: params)
      assert_equal subject.activity_params_global, params
    end

    it 'accepts :on option' do
      on = { a: -> {}, b: proc {} }
      subject.tracked(on: on)
      assert_equal subject.activity_hooks, on
    end

    it 'accepts :on option with string keys' do
      on = { 'a' => -> {} }
      subject.tracked(on: on)
      assert_equal subject.activity_hooks, on.symbolize_keys
    end

    it 'accepts :on values that are procs' do
      on = { unpassable: 1, proper: -> {}, proper_proc: proc {} }
      subject.tracked(on: on)
      assert_includes subject.activity_hooks, :proper
      assert_includes subject.activity_hooks, :proper_proc
      refute_includes subject.activity_hooks, :unpassable
    end

    describe 'global options' do
      subject { article(recipient: :test, owner: :test2, params: { a: 'b' }) }

      specify { assert_equal subject.activity_recipient_global, :test }
      specify { assert_equal subject.activity_owner_global, :test2 }
      specify { assert_equal subject.activity_params_global, a: 'b' }
    end
  end

  describe 'activity hooks' do
    subject do
      s = article
      s.activity_hooks = { test: hook }
      s
    end
    let(:hook) { -> {} }

    it 'retrieves hooks' do
      assert_same hook, subject.get_hook(:test)
    end

    it 'retrieves hooks by string keys' do
      assert_same hook, subject.get_hook('test')
    end

    it 'returns nil when no matching hook is present' do
      assert_same nil, subject.get_hook(:nonexistent)
    end

    it 'allows hooks to decide if activity should be created' do
      subject.tracked
      @article = subject.new(name: 'Some Name')
      PublicActivity.set_controller(mock('controller'))
      pf = proc { |model, controller|
        assert_same controller, PublicActivity.get_controller
        assert_equal model.name, 'Some Name'
        false
      }
      pt = proc { |model, controller|
        assert_same controller, PublicActivity.get_controller
        assert_equal model.name, 'Other Name'
        true # this will save the activity with *.update key
      }
      @article.class.activity_hooks = { create: pf, update: pt, destroy: pt }

      assert_empty @article.activities.to_a
      @article.save # create
      @article.name = 'Other Name'
      @article.save # update
      @article.destroy # destroy

      assert_equal @article.activities.count, 2
      assert_equal @article.activities.first.key, 'article.update'
    end
  end

  def teardown
    PublicActivity.set_controller(nil)
  end
end
