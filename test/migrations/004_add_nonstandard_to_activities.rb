class AddNonstandardToActivities < ActiveRecord::Migration
  def change
    change_table :activities do |t|
      t.string :nonstandard
    end
  end
end
