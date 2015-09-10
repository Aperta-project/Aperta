class CreateNestedQuestionAnswers < ActiveRecord::Migration
  def up
    create_table :nested_question_answers do |t|
      t.integer :nested_question_id
      t.integer :owner_id
      t.string :owner_type
      t.text :value
      t.string :value_type, :null => false

      t.timestamps null: false
    end
  end

  def down
    drop_table :nested_question_answers
  end
end
