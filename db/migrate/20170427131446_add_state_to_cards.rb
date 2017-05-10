class AddStateToCards < ActiveRecord::Migration
  def change
    add_column :cards, :state, :string
    add_index :cards, :state
  end
end
