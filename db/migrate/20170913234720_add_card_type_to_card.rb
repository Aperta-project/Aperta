class AddCardTypeToCard < ActiveRecord::Migration
  def up
    add_column :cards, :card_type, :string, nil: true
    # TODO: Set to name if exists
    execute "UPDATE cards SET card_type = 'CustomCardTask'"
    change_column_null :cards, :card_type, false
  end

  def down
    remove_column :cards, :card_type, :string, nil: false
  end
end
