class CreateRepetitions < ActiveRecord::Migration
  def change
    create_table :repetitions do |t|
      t.references :card_content, null: false
      t.references :task, null: false
      t.integer :parent_id, index: true
      t.integer :lft, index: true
      t.integer :rgt, index: true

      t.timestamps null: false
    end
  end
end
