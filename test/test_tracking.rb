require 'test_helper'

class TestTracking < MiniTest::Unit::TestCase
  def test_defining_instance_options
    @article = article.new
    # TODO: test :owner on real object
    options = {:key => 'key', :params => {:a => 1}}
    @article.activity(options)
    @article.save
    assert_equal(@article.activity_key, options[:key])
    #assert_equal(@article.activity_owner, options[:owner])
    assert_equal(@article.activity_params, options[:params])
    assert_equal(@article.activities.last.key, options[:key])
    #assert_equal(@article.activities.last.owner, options[:owner])
    assert_equal(@article.activities.last.parameters, options[:params])
  end

  def test_creating_activity
    klass = article
    @article = klass.new
    @article.activity :key => 'test'
    @article.save
    assert_equal @article.activities.last.key, 'test'
  end

  def test_tracked_options_skip_defaults
    options = {:skip_defaults => true}
    klass = article(options)
    assert_includes klass.included_modules, PublicActivity::Common
  end
  
  def test_tracked_options_none
    klass = article
    assert_includes klass.included_modules, PublicActivity::Creation
    assert_includes klass.included_modules, PublicActivity::Destruction
    assert_includes klass.included_modules, PublicActivity::Update
    refute_empty klass._create_callbacks.select {|c| c.kind.eql?(:after) && c.filter == :activity_on_create }
    refute_empty klass._update_callbacks.select {|c| c.kind.eql?(:after) && c.filter == :activity_on_update }
    refute_empty klass._destroy_callbacks.select {|c| c.kind.eql?(:before) && c.filter == :activity_on_destroy }
  end

  def test_tracked_options_except
    options = {:except => [:create]}
    klass = article(options)
    assert_includes options[:only], :destroy
    assert_includes options[:only], :update
    refute_includes options[:only], :create
    refute_includes klass.included_modules, PublicActivity::Creation
    assert_includes klass.included_modules, PublicActivity::Destruction
    assert_includes klass.included_modules, PublicActivity::Update
  end

  def test_tracked_options_only
    options = {:only => [:create, :destroy, :update]}
    klass = article(options)
    assert_includes klass.included_modules, PublicActivity::Common
    assert_includes klass.included_modules, PublicActivity::Creation
    assert_includes klass.included_modules, PublicActivity::Destruction
    assert_includes klass.included_modules, PublicActivity::Update
  end

  def test_tracked_options_owner
    options = {:owner => {:a => 1}}
    klass = article(options)
    assert_equal(klass.activity_owner_global, options[:owner], '#tracked :owner option not set')
  end

  def test_tracked_options_params
    options = {:params => {:a => 1}}
    klass = article(options)
    assert_equal(klass.activity_params_global, options[:params], '#tracked :params option not set')
  end

  def test_tracked_options_on
    options = {:on => {:a => lambda {}}}
    klass = article(options)
    assert_equal(klass.activity_hooks, options[:on], '#tracked :on option not set')
  end

  def test_tracked_options_on_symbolize_keys
    options = {:on => {'a' => lambda {}}}
    klass = article(options)
    assert_equal klass.activity_hooks, options[:on].symbolize_keys
  end

  def test_tracked_options_on_proc_values
    options = {:on => {:unpassable => 1, :proper => lambda{}}}
    klass = article(options)
    assert_includes klass.activity_hooks, :proper
    refute_includes klass.activity_hooks, :unpassable
  end

  def test_get_hook
    p = lambda {}
    klass = article
    klass.activity_hooks = {:test => p}
    assert_equal klass.get_hook(:test), p
  end

  def test_get_hook_symbolize_key
    p = lambda {}
    klass = article
    klass.activity_hooks = {:test => p}
    assert_same klass.get_hook('test'), p
  end

  def test_get_hook_on_no_hook_available
    klass = article
    klass.activity_hooks = {}
    assert_same nil, klass.get_hook(:nonexistent)
  end
end
