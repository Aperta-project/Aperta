# Removes old question database table
class DropQuestionTable < ActiveRecord::Migration
  def up
    QuestionAttachment.where(question_type: 'Question').destroy_all
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
    # Migration is not reversable
  end
end
