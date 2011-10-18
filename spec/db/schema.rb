ActiveRecord::Schema.define(:version => 0) do

  create_table :categories, :force => true do |t|
    t.column :name, :string
  end

  create_table :departments, :force => true do |t|
    t.column :name, :string
  end

  create_table :notes, :force => true do |t|
    t.column :body, :text
    t.column :category_id, :integer
  end
  
  create_table :activities, :force => true do |t|
      t.integer  :trackable_id
      t.string   :trackable_type
      t.integer  :owner_id
      t.string   :owner_type
      t.string   :key
      t.text     :parameters
      t.datetime :created_at
      t.datetime :updated_at
  end
    
end
