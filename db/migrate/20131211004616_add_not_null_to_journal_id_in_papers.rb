class AddNotNullToJournalIdInPapers < ActiveRecord::Migration
  def up
    change_column :papers, :journal_id, :integer, null: false
  end

  def down
    change_column :papers, :journal_id, :integer, null: true
  end
end
