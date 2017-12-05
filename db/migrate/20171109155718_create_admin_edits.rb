class CreateAdminEdits < ActiveRecord::Migration
  def change
    create_table :admin_edits do |t|
      t.references :reviewer_report, index: true
      t.references :user, index: true
      t.string :notes
      t.boolean :active

      t.timestamps null: false
    end
  end
end
