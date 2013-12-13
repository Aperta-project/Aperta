class CreatePaperRoles < ActiveRecord::Migration
  def change
    create_table :paper_roles do |t|
      t.references :user, index: true
      t.references :paper, index: true
      t.boolean :editor, default: false, null: false
      t.boolean :reviewer, default: false, null: false

      t.timestamps
    end
  end
end
