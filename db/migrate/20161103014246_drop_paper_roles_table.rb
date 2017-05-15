# PaperRoles are no longer necessary
class DropPaperRolesTable < ActiveRecord::Migration
  def change
    drop_table :paper_roles
  end
end
