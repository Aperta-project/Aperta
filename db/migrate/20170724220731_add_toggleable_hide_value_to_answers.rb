class AddToggleableHideValueToAnswers < ActiveRecord::Migration
  def up
    add_column :answers, :toggleable_hide_value, :boolean, default: false
  end

  def down
    remove_column :answers, :toggleable_hide_value, :boolean
  end
end
