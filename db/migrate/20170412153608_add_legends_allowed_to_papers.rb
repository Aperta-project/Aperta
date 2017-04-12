class AddLegendsAllowedToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :legends_allowed, :boolean, default: false
    execute 'update papers set legends_allowed = true'
  end
end
