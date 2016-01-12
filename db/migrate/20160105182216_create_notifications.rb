class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :paper, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :target_id
      t.string :target_type
      t.integer :parent_id
      t.string :parent_type
      t.string :state

      t.timestamps null: false
    end

    add_index :notifications, [:target_id, :target_type]
  end
end
