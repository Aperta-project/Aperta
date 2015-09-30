class AddDecisionIdToNestedQuestionAnswer < ActiveRecord::Migration
  def change
    add_column :nested_question_answers, :decision_id, :integer
    add_index :nested_question_answers, :decision_id
  end
end
