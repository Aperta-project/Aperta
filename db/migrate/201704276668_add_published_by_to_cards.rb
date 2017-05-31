class AddPublishedByToCards < ActiveRecord::Migration
  def change
    add_column :card_versions, :published_by_id, :integer
    add_index :card_versions, :published_by_id
  end
end
