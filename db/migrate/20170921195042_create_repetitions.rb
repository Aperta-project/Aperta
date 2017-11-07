class CreateRepetitions < ActiveRecord::Migration
  def change
    create_table :repetitions do |t|
      t.references :card_content, null: false
      t.references :task, null: false
      t.integer :parent_id, index: true
      t.integer :position, null: false, default: 0

      t.timestamps null: false
    end

    # create clojure_tree lookup table
    create_table :repetition_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :repetition_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "repetition_anc_desc_idx"

    add_index :repetition_hierarchies, [:descendant_id],
      name: "repetition_desc_idx"

    add_column :answers, :repetition_id, :integer
  end
end
