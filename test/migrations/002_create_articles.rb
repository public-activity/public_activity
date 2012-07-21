class CreateArticles < ActiveRecord::Migration
  def self.up
    puts "creating"
    create_table :articles do |t|
      t.string :name
      t.boolean :published
      t.timestamps
    end
  end
end
   

