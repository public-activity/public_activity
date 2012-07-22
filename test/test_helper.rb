if RUBY_VERSION != "1.8.7"
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
  end
end
$:.unshift File.expand_path('../../lib/', __FILE__)
require 'public_activity'
require 'minitest/autorun'
require 'active_record'
require 'active_record/connection_adapters/sqlite3_adapter'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
ActiveRecord::Migrator.migrate(File.expand_path('../migrations', __FILE__))

def article(options = {})
  Class.new(ActiveRecord::Base) do
    self.abstract_class = true
    self.table_name = 'articles'
    include PublicActivity::Model
    tracked options

    def self.name
      "Article"
    end
  end
end

class User < ActiveRecord::Base

end
