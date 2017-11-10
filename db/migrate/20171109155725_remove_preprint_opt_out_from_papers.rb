class RemovePreprintOptOutFromPapers < ActiveRecord::Migration
  def change
    remove_column :papers, :preprint_opt_out, :boolean, default: false, null: false
  end
end
