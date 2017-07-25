class AddToggleableHideToCardContent < ActiveRecord::Migration
  def up
    add_column :card_contents, :toggleable_hide, :boolean
  end

  def down
    remove_column :card_contents, :toggleable_hide, :boolean
  end
end
