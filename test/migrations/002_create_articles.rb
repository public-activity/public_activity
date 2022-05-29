# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[5.0]
  def self.up
    create_table :articles do |t|
      t.string :name
      t.boolean :published
      t.belongs_to :user
      t.timestamps
    end
  end
end
