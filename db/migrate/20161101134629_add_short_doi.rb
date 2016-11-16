class AddShortDoi < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        add_index :journals, :doi_journal_prefix, unique: true
        add_column :papers, :short_doi, :string
        add_index :papers, :short_doi, unique: true
      end

      dir.down do
        remove_index :journals, :doi_journal_prefix
        remove_column :papers, :short_doi
      end
    end
  end
end
