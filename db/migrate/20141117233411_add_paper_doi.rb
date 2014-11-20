class AddPaperDoi < ActiveRecord::Migration
  def change
    add_column :journals, :doi_publisher_prefix, :string
    add_column :journals, :doi_journal_prefix, :string
    add_column :journals, :last_doi_issued, :string
  end
end
