class AddPreprintDoiShortIdToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :preprint_doi_short_id, :string
  end
end
