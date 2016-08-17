class AddDeletedAtToNestedQuestions < ActiveRecord::Migration
  def change
    add_column :nested_questions, :deleted_at, :datetime
    add_column :nested_question_answers, :deleted_at, :datetime
  end
end
