class AddIfConditionToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :condition, :string
  end
end
