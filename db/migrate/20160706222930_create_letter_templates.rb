class CreateLetterTemplates < ActiveRecord::Migration
  def change
    create_table :letter_templates do |t|
      t.string :text
      t.string :template_decision
      t.string :to
      t.string :subject
      t.text :letter
      t.integer :journal_id
      t.timestamps
    end
  end
end
