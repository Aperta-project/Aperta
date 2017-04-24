class AddFilterByCardIdToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :filter_by_card_id, :integer
    add_foreign_key :permissions, :cards, column: :filter_by_card_id
  end
end
