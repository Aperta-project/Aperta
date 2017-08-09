class AddRevertChildrenOnHideToCardContent < ActiveRecord::Migration
  def up
    add_column :card_contents, :revert_children_on_hide, :boolean
  end

  def down
    remove_column :card_contents, :revert_children_on_hide, :boolean
  end
end
