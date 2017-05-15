class AddConfigToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :config, :jsonb
  end
end
