class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.references :user, index: true
      t.references :journal, index: true
      t.boolean :editor, default: false, null: false
      t.boolean :reviewer, default: false, null: false

      t.timestamps
    end
  end
end
