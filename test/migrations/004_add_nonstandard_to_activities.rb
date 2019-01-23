# frozen_string_literal: true

require 'migrations_base.rb'

class AddNonstandardToActivities < MigrationsBase
  def change
    change_table :activities do |t|
      t.string :nonstandard
    end
  end
end
