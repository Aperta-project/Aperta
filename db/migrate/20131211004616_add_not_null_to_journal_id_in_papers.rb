class AddNotNullToJournalIdInPapers < ActiveRecord::Migration
  def change
    change_column :papers, :journal_id, :integer, null: false
  end
end
