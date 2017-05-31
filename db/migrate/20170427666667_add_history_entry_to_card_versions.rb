class AddHistoryEntryToCardVersions < ActiveRecord::Migration
  def change
    add_column :card_versions, :history_entry, :string
  end
end
