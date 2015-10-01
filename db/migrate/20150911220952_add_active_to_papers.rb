class AddActiveToPapers < ActiveRecord::Migration
  def up
    add_column :papers, :active, :boolean, default: true
    execute "UPDATE papers SET active=false WHERE publishing_state='withdrawn';"
    execute "UPDATE papers SET active=false WHERE publishing_state='rejected';"
  end

  def down
    remove_column :papers, :active
  end
end
