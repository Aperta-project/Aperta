class AddPreprintShortDoiToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :preprint_short_doi, :string
  end
end
