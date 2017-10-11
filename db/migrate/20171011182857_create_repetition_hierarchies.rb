class CreateRepetitionHierarchies < ActiveRecord::Migration
  def change
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
  end
end
