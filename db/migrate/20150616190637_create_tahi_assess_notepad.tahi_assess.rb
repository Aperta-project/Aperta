# This migration comes from tahi_assess (originally 20150608223124)
class CreateTahiAssessNotepad < ActiveRecord::Migration
  def change
    create_table :tahi_assess_notepads do |t|
      t.integer :user_id, null: false
      t.integer :paper_id, null: false
      t.text :body, default: ''

      t.timestamps
    end

    add_index :tahi_assess_notepads, [:user_id, :paper_id], unique: true
  end
end
