class AddPublishedToCardVersions < ActiveRecord::Migration
  def change
    add_column :card_versions, :published, :boolean, null: false, default: false
    add_index :card_versions, :published
  end
end
