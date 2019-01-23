# frozen_string_literal: true

require "rubygems"
require "bundler"
Bundler.setup(:default, :test)

if ENV['COV']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
  end
end
$:.unshift File.expand_path('../../lib/', __FILE__)
require 'active_support/testing/setup_and_teardown'
require 'public_activity'
require 'public_activity/testing'
require 'pry'
require 'minitest/autorun'
require 'mocha/minitest'

PublicActivity::Config.orm = (ENV['PA_ORM'] || :active_record)

case PublicActivity::Config.orm
when :active_record
  require 'active_record'
  require 'active_record/connection_adapters/sqlite3_adapter'
  require 'stringio'        # silence the output
  $stdout = StringIO.new    # from migrator
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

  migrations_path = File.expand_path('../migrations', __FILE__)

  if ActiveRecord.version.release() < Gem::Version.new('5.2.0')
    ActiveRecord::Migrator.migrate(migrations_path)
  else
    ActiveRecord::MigrationContext.new(migrations_path).migrate
  end

  $stdout = STDOUT

  def article(options = {})
    klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'articles'
      include PublicActivity::Model
      tracked options
      belongs_to :user

      def self.name
        "Article"
      end

      if ::ActiveRecord::VERSION::MAJOR < 4
        attr_accessible :name, :published, :user
      end
    end
    klass
  end
  class User < ActiveRecord::Base; end

  if ::ActiveRecord::VERSION::MAJOR < 4
    PublicActivity::Activity.class_eval do
      attr_accessible :nonstandard
    end
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

    if ::Mongoid::VERSION.split('.')[0].to_i >= 7
      belongs_to :user, optional: true
    else
      belongs_to :user
    end

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

when :mongo_mapper
  require 'mongo_mapper'

  config = YAML.load(File.read("test/mongo_mapper.yml"))
  MongoMapper.setup(config, :test)

  class User
    include MongoMapper::Document

    has_many :articles

    key :name, String
    timestamps!
  end

  class Article
    include MongoMapper::Document
    include PublicActivity::Model

    belongs_to :user

    key :name, String
    key :published, Boolean
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
  if ActiveSupport.version >= Gem::Version.new('5.2.0')
    prepend ActiveSupport::Testing::SetupAndTeardown
  else
    include ActiveSupport::Testing::SetupAndTeardown
  end
  include ActionView::TestCase::Behavior
end
MiniTest::Spec.register_spec_type(/Rendering$/, ViewSpec)
