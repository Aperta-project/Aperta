class AddRolePermissions < ActiveRecord::Migration
  def change
    add_column :roles, :can_administer_journal, :boolean, default: false, null: false
    add_column :roles, :can_view_assigned_manuscript_managers, :boolean, default: false, null: false
    add_column :roles, :can_view_all_manuscript_managers, :boolean, default: false, null: false
  end
end
