class AddIndexNestedQuestionIdent < ActiveRecord::Migration
  def change
    add_index :nested_questions, :ident
  end
end
