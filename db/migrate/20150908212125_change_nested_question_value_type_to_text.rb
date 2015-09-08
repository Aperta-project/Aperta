class ChangeNestedQuestionValueTypeToText < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE nested_questions SET value_type='text' WHERE value_type IS NULL;
    SQL

    change_column :nested_questions, :value_type, :text, null: false
  end

  def down
    change_column_default :nested_questions, :value_type, nil
  end
end
