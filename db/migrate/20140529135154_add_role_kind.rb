class AddRoleKind < ActiveRecord::Migration
  def up
    add_column :roles, :kind, :string, null: false, default: Role::CUSTOM
    add_index :roles, :kind

    Role.where(admin: true).update_all(kind: Role::ADMIN)
    Role.where(reviewer: true).update_all(kind: Role::REVIEWER)
    Role.where(editor: true).update_all(kind: Role::EDITOR)

    remove_column :roles, :admin
    remove_column :roles, :reviewer
    remove_column :roles, :editor
  end

  def down
    add_column :roles, :editor, :boolean
    add_column :roles, :reviewer, :boolean
    add_column :roles, :admin, :boolean

    Role.where(kind: Role::ADMIN).update_all(admin: true)
    Role.where(kind: Role::REVIEWER).update_all(reviewer: true)
    Role.where(kind: Role::EDITOR).update_all(editor: true)

    remove_column :roles, :kind
  end
end
