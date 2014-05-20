class AddRoles < ActiveRecord::Migration
  def up
    create_table :roles do |t|
      t.string :name
      t.boolean :admin, null: false, default: false
      t.boolean :editor, null: false, default: false
      t.boolean :reviewer, null: false, default: false

      t.references :journal

      t.timestamps
    end

    add_column :journal_roles, :role_id, :integer
    add_index :journal_roles, :role_id

    Journal.all.each do |journal|
      admin = Role.create!(journal: journal, name: "Journal Admin", admin: true)
      editor = Role.create!(journal: journal, name: "Editor", editor: true)
      reviewer = Role.create!(journal: journal, name: "Reviewer", reviewer: true)

      JournalRole.where(journal: journal, reviewer: true).update_all(role_id: reviewer.id)
      JournalRole.where(journal: journal, editor: true).update_all(role_id: editor.id)
      JournalRole.where(journal: journal, admin: true).update_all(role_id: admin.id)
    end

    remove_column :journal_roles, :editor
    remove_column :journal_roles, :admin
    remove_column :journal_roles, :reviewer
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
