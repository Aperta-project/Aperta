class LinkTaskToCard < ActiveRecord::Migration
  def change
    add_column :tasks, :card_id, :integer, index: true
  end
end
