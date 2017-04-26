class AddArchivedAtToCards < ActiveRecord::Migration
  def change
    add_column :cards, :archived_at, :datetime
  end
end
