class PaperRole < ActiveRecord::Base
end

class ConvertPaperRoleFlags < ActiveRecord::Migration
  def up
    add_column :paper_roles, :role, :string

    PaperRole.where(reviewer: true).update_all(role: 'reviewer')
    PaperRole.where(editor: true).update_all(role: 'editor')
    PaperRole.where(admin: true).update_all(role: 'admin')

    remove_column :paper_roles, :reviewer
    remove_column :paper_roles, :editor
    remove_column :paper_roles, :admin

    add_index :paper_roles, :role
  end

  def down
    add_column :paper_roles, :reviewer, :boolean, default: false, null: false
    add_column :paper_roles, :editor, :boolean, default: false, null: false
    add_column :paper_roles, :admin, :boolean, default: false, null: false

    PaperRole.where(role: 'reviewer').update_all(reviewer: true)
    PaperRole.where(role: 'editor').update_all(editor: true)
    PaperRole.where(role: 'admin').update_all(admin: true)

    remove_column :paper_roles, :role
  end
end
