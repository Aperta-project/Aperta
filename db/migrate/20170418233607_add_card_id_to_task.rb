class AddCardIdToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :card_id, :integer
    add_foreign_key :tasks, :cards
  end
end
