# Initial version of CardContent model
class CreateCardContents < ActiveRecord::Migration
  def change
    create_table :card_contents do |t|
      t.references :card
      t.string :ident, index: true
      t.integer :parent_id, index: true
      t.integer :lft, null: false, index: true
      t.integer :rgt, null: false, index: true
      t.string :text
      t.string :value_type

      t.timestamps null: false
    end
  end
end
