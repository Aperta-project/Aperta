class CreateJournalTaskTypes < ActiveRecord::Migration
  def change
    create_table :journal_task_types do |t|
      t.json :template
      t.references :task_type, index: true
      t.references :journal, index: true
      t.string :title
      t.string :role
    end
  end
end
