class AddErrorMessageToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :error_message, :string
  end
end
