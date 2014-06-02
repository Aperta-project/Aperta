class AddRoleKind < ActiveRecord::Migration
  def up
    add_column :roles, :kind, :string, null: false, default: Role::CUSTOM
    add_index :roles, :kind
  end

  def down
    remove_column :roles, :kind
  end

  def data
    Role.where(admin: true).update_all(kind: Role::ADMIN)
    Role.where(reviewer: true).update_all(kind: Role::REVIEWER)
    Role.where(editor: true).update_all(kind: Role::EDITOR)
  end
end
