class AddPublishedToCardVersions < ActiveRecord::Migration
  def change
    add_column :card_versions, :published_at, :datetime
  end
end
