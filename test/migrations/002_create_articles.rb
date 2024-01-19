# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[6.1]
  def self.up
    create_table :articles do |t|
      t.string :name
      t.boolean :published
      t.belongs_to :user
      t.timestamps
    end
  end
end
