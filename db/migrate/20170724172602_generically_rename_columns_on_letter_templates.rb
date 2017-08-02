class GenericallyRenameColumnsOnLetterTemplates < ActiveRecord::Migration
  def change
    rename_column :letter_templates, :letter, :body
    rename_column :letter_templates, :text, :name
    rename_column :letter_templates, :template_decision, :category
  end
end
