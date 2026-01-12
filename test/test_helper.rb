# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'logger'
Bundler.setup(:default, :test)

if ENV['COV']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
  end
end
$:.unshift File.expand_path('../lib', __dir__)
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
  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

  migrations_path = File.expand_path('migrations', __dir__)
  active_record_version = ActiveRecord.version.release

  if active_record_version >= Gem::Version.new('7.2.0')
    migration_context = ActiveRecord::MigrationContext.new(migrations_path)
    migrations = migration_context.migrations   # => Array<ActiveRecord::MigrationProxy>
    connection_pool = ActiveRecord::Tasks::DatabaseTasks.migration_connection_pool
    schema_migration = ActiveRecord::SchemaMigration.new(connection_pool)
    internal_metadata = ActiveRecord::InternalMetadata.new(connection_pool)

    ActiveRecord::Migrator.new(
      :up,
      migrations,
      schema_migration,
      internal_metadata
    ).migrate
  else
    ActiveRecord::MigrationContext.new(migrations_path, ActiveRecord::SchemaMigration).migrate
  end

  $stdout = STDOUT

  def article(options = {})
    Class.new(ActiveRecord::Base) do
      self.table_name = 'articles'
      include PublicActivity::Model
      tracked options
      belongs_to :user

      def self.name
        'Article'
      end
    end
  end

  class User < ActiveRecord::Base; end
when :mongoid
  require 'mongoid'

  Mongoid.load!(File.expand_path('test/mongoid.yml'), :test)

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

  config = YAML.safe_load(File.read('test/mongo_mapper.yml'), aliases: true)
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

class ViewSpec < Minitest::Spec
  prepend ActiveSupport::Testing::SetupAndTeardown
  include ActionView::TestCase::Behavior
end
Minitest::Spec.register_spec_type(/Rendering$/, ViewSpec)
