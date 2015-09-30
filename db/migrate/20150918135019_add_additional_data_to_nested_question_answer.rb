class AddAdditionalDataToNestedQuestionAnswer < ActiveRecord::Migration
  def change
    add_column :nested_question_answers, :additional_data, :json
  end
end
