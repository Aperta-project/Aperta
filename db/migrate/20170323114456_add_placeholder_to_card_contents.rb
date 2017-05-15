class AddPlaceholderToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :placeholder, :string
  end
end
