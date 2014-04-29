class CreateManuscriptManagerTemplates < ActiveRecord::Migration
  def change
    create_table :manuscript_manager_templates do |t|
      t.string :name
      t.string :paper_type
      t.json :template
      t.integer :journal_id
    end

    add_index :manuscript_manager_templates, :journal_id
  end
end
