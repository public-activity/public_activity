require "rubygems"
require "bundler"
Bundler.setup(:default, :test)

if not ENV['NOCOV']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
  end
end
$:.unshift File.expand_path('../../lib/', __FILE__)
require 'active_support/testing/setup_and_teardown'
require 'public_activity'
require 'minitest/autorun'
require 'minitest/pride' if ENV['WITH_PRIDE'] or ENV['PRIDE']

PublicActivity::Config.orm = (ENV['PA_ORM'] || :active_record)

PublicActivity.config # touch config to load ORM, needed in some separate tests

case PublicActivity::Config.orm
when :active_record
  require 'active_record'
  require 'active_record/connection_adapters/sqlite3_adapter'
  require 'stringio'        # silence the output
  $stdout = StringIO.new    # from migrator
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
  ActiveRecord::Migrator.migrate(File.expand_path('../migrations', __FILE__))
  $stdout = STDOUT

  def article(options = {})
    klass = Class.new(ActiveRecord::Base) do
      self.abstract_class = true
      self.table_name = 'articles'
      include PublicActivity::Model
      tracked options

      belongs_to :user

      def self.name
        "Article"
      end
    end
    klass
  end

  class User < ActiveRecord::Base; end

  PublicActivity::Activity.class_eval do
      attr_accessible :nonstandard
  end

when :mongoid
  require 'mongoid'

  Mongoid.load!(File.expand_path("test/mongoid.yml"), :test)

  class User
    include Mongoid::Document
    include Mongoid::Timestamps

    has_many :articles

    field :name, type: String
  end

  class Article
    include Mongoid::Document
    include Mongoid::Timestamps
    include PublicActivity::Model

    belongs_to :user

    field :name, type: String
    field :published, type: Boolean
  end

  def article(options = {})
    Article.class_eval do
      set_public_activity_class_defaults
      tracked options
    end
    Article
  end
end

class ViewSpec < MiniTest::Spec
  include ActiveSupport::Testing::SetupAndTeardown
  include ActionView::TestCase::Behavior
end
MiniTest::Spec.register_spec_type(/Rendering$/, ViewSpec)

if PublicActivity::Config.orm == :mongoid && ENV['PA_PURGE']
  # takes under half a second for the whole suite
  MiniTest::Spec.class_eval do
    before :each do
      Mongoid::Config.purge!
    end
  end
end
