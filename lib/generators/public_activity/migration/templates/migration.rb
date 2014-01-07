# Migration responsible for creating a table with activities
class Create<%= PublicActivity.config.table_name.camelize %> < ActiveRecord::Migration
  # Create table
  def self.up
    create_table :<%= PublicActivity.config.table_name %> do |t|
      t.belongs_to :trackable, :polymorphic => true
      t.belongs_to :owner, :polymorphic => true
      t.string  :key
      t.text    :parameters
      t.belongs_to :recipient, :polymorphic => true

      t.timestamps
    end

    add_index :<%= PublicActivity.config.table_name %>, [:trackable_id, :trackable_type]
    add_index :<%= PublicActivity.config.table_name %>, [:owner_id, :owner_type]
    add_index :<%= PublicActivity.config.table_name %>, [:recipient_id, :recipient_type]
  end
  # Drop table
  def self.down
    drop_table :<%= PublicActivity.config.table_name %>
  end
end
