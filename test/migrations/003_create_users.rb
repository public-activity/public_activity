# frozen_string_literal: true

require 'migrations_base.rb'

class CreateUsers < MigrationsBase
  def self.up
    create_table :users do |t|
      t.string :name
      t.timestamps
    end
  end
end
