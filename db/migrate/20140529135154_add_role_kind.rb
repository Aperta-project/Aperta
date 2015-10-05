class AddRoleKind < ActiveRecord::Migration
  def up
    add_column :roles, :kind, :string, null: false, default: "custom"
    add_index :roles, :kind
  end

  def down
    remove_column :roles, :kind
  end

  def data
    Role.where(admin: true).update_all(kind: "admin")
    Role.where(reviewer: true).update_all(kind: "reviewer")
    Role.where(editor: true).update_all(kind: "editor")
  end
end
