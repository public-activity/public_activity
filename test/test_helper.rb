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
require 'minitest/pride' if ENV['WITH_PRIDE']
require 'active_record'
require 'active_record/connection_adapters/sqlite3_adapter'
require 'turn/autorun' if !ENV['CI']

require 'stringio'        # silence the output
$stdout = StringIO.new    # from migrator
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
ActiveRecord::Migrator.migrate(File.expand_path('../migrations', __FILE__))
$stdout = STDOUT

def article(options = {})
  Class.new(ActiveRecord::Base) do
    self.abstract_class = true
    self.table_name = 'articles'
    include PublicActivity::Model
    tracked options if options

    belongs_to :user

    def self.name
      "Article"
    end
  end
end

class User < ActiveRecord::Base; end

class ViewSpec < MiniTest::Spec
  include ActiveSupport::Testing::SetupAndTeardown
  include ActionView::TestCase::Behavior
end
MiniTest::Spec.register_spec_type(/Rendering$/, ViewSpec)
