class JournalDoiFilesRequired < ActiveRecord::Migration
  def change
    change_column :journals, :doi_publisher_prefix, :string, :null => false
    change_column :journals, :doi_journal_prefix, :string, :null => false
    change_column :journals, :last_doi_issued, :string, :null => false
  end
end
