class RemovePreprintOptOutFromPapers < ActiveRecord::Migration
  def change
    remove_column :papers, :preprint_opt_out, :boolean
  end
end
