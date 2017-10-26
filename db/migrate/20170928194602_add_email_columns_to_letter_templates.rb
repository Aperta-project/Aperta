class AddEmailColumnsToLetterTemplates < ActiveRecord::Migration
  def change
    add_column :letter_templates, :cc, :string
    add_column :letter_templates, :bcc, :string
  end
end
