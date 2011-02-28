class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.belongs_to :tracked, :polymorphic => true
      t.belongs_to :user
      t.string  :key
      t.text    :options

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
