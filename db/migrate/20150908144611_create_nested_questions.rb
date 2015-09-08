class CreateNestedQuestions < ActiveRecord::Migration

  def change
    create_table :nested_questions do |t|
      t.string :text
      t.string :value_type
      t.string :value

      t.integer :parent_id, :null => true, :index => true
      t.integer :lft, :null => false, :index => true
      t.integer :rgt, :null => false, :index => true
      t.integer :position

      t.timestamps null: false

      t.string :owner_type
      t.integer :owner_id

      # optional fields
      t.integer :depth, :null => false, :default => 0
      t.integer :children_count, :null => false, :default => 0
    end
  end
end
