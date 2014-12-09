class AddDefaultLastIssuedDoiToJournal < ActiveRecord::Migration
  def up
    change_column :journals, :last_doi_issued, :string, default: "0", null: false
  end

  def down
    change_column :journals, :last_doi_issued, :string
  end
end
