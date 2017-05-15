# Add deleted_at to tables
class MakeCustomCardModelsParanoid < ActiveRecord::Migration
  def change
    add_column :answers, :deleted_at, :datetime
    add_column :cards, :deleted_at, :datetime
    add_column :card_contents, :deleted_at, :datetime
  end
end
