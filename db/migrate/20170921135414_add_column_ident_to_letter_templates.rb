class AddColumnIdentToLetterTemplates < ActiveRecord::Migration
  def change
    add_column :letter_templates, :ident, :string
    add_index :letter_templates, [:ident, :journal_id], unique: true
  end
end
