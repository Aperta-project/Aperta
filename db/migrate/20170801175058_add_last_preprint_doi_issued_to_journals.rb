class AddLastPreprintDoiIssuedToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :last_preprint_doi_issued, :string, default: "0", null: false
  end
end
