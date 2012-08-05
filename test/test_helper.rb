if RUBY_VERSION != "1.8.7"
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
  end
end
$:.unshift File.expand_path('../../lib/', __FILE__)
require 'public_activity'
require 'minitest/autorun'
require 'mocha'
require 'active_record'
require 'active_record/connection_adapters/sqlite3_adapter'

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
    tracked options

    belongs_to :user

    def self.name
      "Article"
    end
  end
end

class User < ActiveRecord::Base; end
