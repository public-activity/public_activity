# frozen_string_literal: true

class AddNonstandardToActivities < ActiveRecord::Migration[5.0]
  def change
    change_table :activities do |t|
      t.string :nonstandard
    end
  end
end
