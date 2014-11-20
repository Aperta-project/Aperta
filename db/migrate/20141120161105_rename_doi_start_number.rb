class RenameDoiStartNumber < ActiveRecord::Migration
  def change
    rename_column :journals, :doi_start_number, :last_doi_issued
  end
end
