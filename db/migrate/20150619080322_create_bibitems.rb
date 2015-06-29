class CreateBibitems < ActiveRecord::Migration
  def change
    create_table :bibitems do |t|
      t.integer :paper_id, index: true
      t.string :type
      t.text :content

      t.timestamps null: false
    end
  end
end
