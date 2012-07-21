$:.unshift File.expand_path('../../lib/', __FILE__)
require 'public_activity'
require 'minitest/autorun'
require 'mocha'
require 'active_record'
require 'active_record/connection_adapters/sqlite3_adapter'

class Article < ActiveRecord::Base
  include PublicActivity::Model

  # #tracked method should be executed in every test group
  # since different options should be tested
  # tracked
end


ActiveRecord::Base.establish_connection {:adapter => 'sqlite3', :database => ':memory:'}
ActiveRecord::Migrator.migrate(File.expand_path('../migrations', __FILE__))
