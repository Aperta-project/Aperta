class AddIndexToLetterTemplatesName < ActiveRecord::Migration
  def change
    add_index :letter_templates, [:name, :journal_id], unique: true
    change_column_null :letter_templates, :name, false
  end
end
