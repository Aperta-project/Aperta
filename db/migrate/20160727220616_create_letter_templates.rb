# Letter Templates are templates that can be used to populate fields
# which are edited by the user before being emailed
class CreateLetterTemplates < ActiveRecord::Migration
  def up
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

  def down
    drop_table :letter_templates
  end
end
