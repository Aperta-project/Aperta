class AddLegendsAllowedToPapers < ActiveRecord::Migration
  def up
    add_column :papers, :legends_allowed, :boolean, default: false, null: false
    execute 'update papers set legends_allowed = true'
  end

  def down
    remove_column :papers, :legends_allowed
  end
end
