class AddErrorMessageToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :error_message, :string
    Card.connection.schema_cache.clear!
    Card.reset_column_information
  end
end
