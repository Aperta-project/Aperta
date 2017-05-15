class AddLabelToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :label, :string
  end
end
