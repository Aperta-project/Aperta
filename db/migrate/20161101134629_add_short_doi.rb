class AddShortDoi < ActiveRecord::Migration
  class Paper < ActiveRecord::Base
  end

  def change
    reversible do |dir|
      dir.up do
        add_index :journals, :doi_journal_prefix, unique: true
        add_column :papers, :short_doi, :string
        add_index :papers, :short_doi, unique: true

        Paper.all.each do |p|
          parts = p.doi.split('/').last.split('.')
          p.short_doi = parts[-2] + '.' + parts[-1]
        end
      end

      dir.down do
        remove_index :journals, :doi_journal_prefix
        remove_column :papers, :short_doi
      end
    end
  end
end
