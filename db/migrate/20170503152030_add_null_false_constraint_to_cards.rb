class AddNullFalseConstraintToCards < ActiveRecord::Migration
  def up
    change_column :cards, :state, :string, null: false
  end

  def down
    change_column :cards, :state, :string
  end
end
