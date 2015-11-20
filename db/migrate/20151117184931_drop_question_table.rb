# Removes old question database table
class DropQuestionTable < ActiveRecord::Migration
  def up
    execute("DELETE FROM question_attachments WHERE question_type = 'Question'")
    drop_table :questions

    remove_column :question_attachments, :question_type
    rename_column :question_attachments, :question_id, \
                  :nested_question_answer_id

    remove_column :authors, :corresponding
    remove_column :authors, :deceased
    remove_column :authors, :contributions

    remove_column :tahi_standard_tasks_funders, :funder_had_influence
    remove_column :tahi_standard_tasks_funders, :funder_influence_description
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
