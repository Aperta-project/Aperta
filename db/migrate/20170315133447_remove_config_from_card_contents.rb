class RemoveConfigFromCardContents < ActiveRecord::Migration
  def change
    remove_column :card_contents, :config, :jsonb
  end
end
