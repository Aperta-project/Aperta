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

    remove_column :journal_roles, :editor
    remove_column :journal_roles, :admin
    remove_column :journal_roles, :reviewer
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
