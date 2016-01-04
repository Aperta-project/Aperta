class AddUniqueIndexToNestedQuestionIdent < ActiveRecord::Migration
  def change
    remove_index :nested_questions, :ident
    add_index :nested_questions, :ident, unique: true
  end
end
