# frozen_string_literal: true

# Migration responsible for creating a table with activities
class CreateActivities < ActiveRecord::Migration[6.1]
  def self.up
    create_table :activities do |t|
      t.belongs_to :trackable, polymorphic: true
      t.belongs_to :owner, polymorphic: true
      t.string :key
      t.text :parameters
      t.belongs_to :recipient, polymorphic: true

      t.timestamps
    end
  end

  # Drop table
  def self.down
    drop_table :activities
  end
end
