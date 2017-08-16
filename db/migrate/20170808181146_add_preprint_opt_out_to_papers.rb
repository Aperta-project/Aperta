class AddPreprintOptOutToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :preprint_opt_out, :boolean, default: false, null: false
  end
end
