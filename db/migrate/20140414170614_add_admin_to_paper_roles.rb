class AddAdminToPaperRoles < ActiveRecord::Migration
  def change
    add_column :paper_roles, :admin, :boolean, default: false, nullable: false
  end
end
