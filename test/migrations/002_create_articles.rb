class CreateArticles < ActiveRecord::Migration
  def self.up
    puts "creating"
    create_table :articles do |t|
      t.string :name
      t.boolean :published
      t.belongs_to :user
      t.timestamps
    end
  end
end