class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables do |t|
      t.integer :paper_id, index: true
      t.string :title
      t.string :caption
      t.text :body

      t.timestamps null: false
    end
  end
end
