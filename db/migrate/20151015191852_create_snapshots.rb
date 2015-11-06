class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.string :source_type
      t.integer :source_id
      t.integer :paper_id
      t.integer :major_version
      t.integer :minor_version

      t.json :contents

      t.timestamps null: false
    end
  end
end
