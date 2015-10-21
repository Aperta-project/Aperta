class AddAdditionalDataToNestedQuestions < ActiveRecord::Migration
  def change
    add_column :nested_questions, :additional_data, :string
  end
end
