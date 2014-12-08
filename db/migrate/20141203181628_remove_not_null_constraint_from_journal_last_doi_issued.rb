class RemoveNotNullConstraintFromJournalLastDoiIssued < ActiveRecord::Migration
  def change
    change_column :journals, :last_doi_issued, :string, default: "0", null: true
  end

  def down
    change_column :journals, :last_doi_issued, :string, default: "0", null: false
  end
end
