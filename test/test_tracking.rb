require 'test_helper'

describe PublicActivity::Tracked do
  describe 'defining instance options' do
    subject { article.new }
    let :options do
      { :key => 'key',
        :params => {:a => 1},
        :owner => User.create,
        :recipient => User.create }
    end
    before(:each) { subject.activity(options) }
    let(:activity){ subject.save; subject.activities.last }

    specify { subject.activity_key.must_be_same_as    options[:key] }
    specify { activity.key.must_equal                 options[:key] }

    specify { subject.activity_owner.must_be_same_as  options[:owner] }
    specify { activity.owner.must_equal               options[:owner] }

    specify { subject.activity_params.must_be_same_as options[:params] }
    specify { activity.parameters.must_equal          options[:params] }

    specify { subject.activity_recipient.must_be_same_as options[:recipient] }
    specify { activity.recipient.must_equal              options[:recipient] }
  end

  describe '#tracked' do
    subject { article(nil) }

    it 'allows skipping the tracking on CRUD actions' do
      subject.tracked(:skip_defaults => true)
      subject.must_include PublicActivity::Common
      subject.wont_include PublicActivity::Creation
      subject.wont_include PublicActivity::Update
      subject.wont_include PublicActivity::Destruction
    end

    describe 'default options' do
      subject { article }

      specify { subject.must_include PublicActivity::Creation }
      specify { subject.must_include PublicActivity::Destruction }
      specify { subject.must_include PublicActivity::Update }

      specify { subject._create_callbacks.select do |c|
        c.kind.eql?(:after) && c.filter == :activity_on_create
      end.wont_be_empty }

      specify { subject._update_callbacks.select do |c|
        c.kind.eql?(:after) && c.filter == :activity_on_update
      end.wont_be_empty }

      specify { subject._destroy_callbacks.select do |c|
        c.kind.eql?(:before) && c.filter == :activity_on_destroy
      end.wont_be_empty }
    end

    it 'accepts :except option' do
      options = {:except => [:create]}
      subject.tracked(options)
      options[:only].wont_include :create
      options[:only].must_include :update
      options[:only].must_include :destroy

      subject.wont_include PublicActivity::Creation
      subject.must_include PublicActivity::Update
      subject.must_include PublicActivity::Destruction
    end

    it 'accepts :only option' do
      options = {:only => [:create, :update]}
      subject.tracked(options)
      subject.must_include PublicActivity::Common
      subject.must_include PublicActivity::Creation
      subject.wont_include PublicActivity::Destruction
      subject.must_include PublicActivity::Update
    end

    it 'accepts :owner option' do
      owner = mock('owner')
      subject.tracked(:owner => owner)
      subject.activity_owner_global.must_equal owner
    end

    it 'accepts :params option' do
      params = {:a => 1}
      subject.tracked(:params => params)
      subject.activity_params_global.must_equal params
    end

    it 'accepts :on option' do
      on = {:a => lambda{}, :b => proc {}}
      subject.tracked(:on => on)
      subject.activity_hooks.must_equal on
    end

    it 'accepts :on option with string keys' do
      on = {'a' => lambda {}}
      subject.tracked(:on => on)
      subject.activity_hooks.must_equal on.symbolize_keys
    end

    it 'accepts :on values that are procs' do
      on = {:unpassable => 1, :proper => lambda {}, :proper_proc => proc {}}
      subject.tracked(:on => on)
      subject.activity_hooks.must_include :proper
      subject.activity_hooks.must_include :proper_proc
      subject.activity_hooks.wont_include :unpassable
    end
  end

  describe 'activity hooks' do
    subject { s = article; s.activity_hooks = {:test => hook}; s }
    let(:hook) { lambda {} }

    it 'retrieves hooks' do
      assert_same hook, subject.get_hook(:test)
    end

    it 'retrieves hooks by string keys' do
      assert_same hook, subject.get_hook('test')
    end

    it 'returns nil when no matching hook is present' do
      nil.must_be_same_as subject.get_hook(:nonexistent)
    end

    it 'allows hooks to decide if activity should be created' do
      subject.tracked
      @article = subject.new(:name => 'Some Name')
      PublicActivity.set_controller(mock('controller'))
      pf = proc { |model, controller|
        controller.must_be_same_as PublicActivity.get_controller
        model.name.must_equal 'Some Name'
        false
      }
      pt = proc { |model, controller|
        controller.must_be_same_as PublicActivity.get_controller
        model.name.must_equal 'Other Name'
        true # this will save the activity with *.update key
      }
      @article.class.activity_hooks = {:create => pf, :update => pt, :destroy => pt}

      @article.activities.must_be_empty
      @article.save # create
      @article.name = 'Other Name'
      @article.save # update
      @article.destroy # destroy

      @article.activities.count.must_equal 2
      @article.activities.first.key.must_equal 'article.update'
    end
  end
end
