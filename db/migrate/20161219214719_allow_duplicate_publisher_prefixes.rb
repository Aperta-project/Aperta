class AllowDuplicatePublisherPrefixes < ActiveRecord::Migration
  def change
    remove_index :journals, :doi_publisher_prefix
    remove_index :journals, :doi_journal_prefix
    add_index :journals, [:doi_publisher_prefix, :doi_journal_prefix], name: "unique_doi", unique: true, using: :btree
  end
end
