class AddAdminToJournalRoles < ActiveRecord::Migration
  def change
    add_column :journal_roles, :admin, :boolean
  end
end
