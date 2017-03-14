# remove the foreign key
class RemoveCardIdFromCardContent < ActiveRecord::Migration
  def change
    remove_column :card_contents, :card_id, :integer, index: true
  end
end
