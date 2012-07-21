$:.unshift File.expand_path('../../lib/', __FILE__)
require 'public_activity'
require 'test/unit'
require 'mocha'
require 'active_record'
require 'active_record/connection_adapters/sqlite3_adapter'

$db = {:adapter => 'sqlite3', :database => ':memory:'}

class Article < ActiveRecord::Base
  include PublicActivity::Model

  # #tracked method should be executed in every test group
  # since different options should be tested
  # tracked
end


ActiveRecord::Base.establish_connection $db
ActiveRecord::Migrator.migrate(File.expand_path('../migrations', __FILE__))
