class AddContentTypeToCardContent < ActiveRecord::Migration
  def change
    add_column :card_contents, :content_type, :string
    add_column :card_contents, :config, :jsonb
  end
end
