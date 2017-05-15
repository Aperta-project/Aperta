class AddContentTypeToCardContent < ActiveRecord::Migration
  def change
    add_column :card_contents, :content_type, :string
  end
end
