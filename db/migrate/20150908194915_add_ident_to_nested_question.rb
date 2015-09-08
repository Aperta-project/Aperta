class AddIdentToNestedQuestion < ActiveRecord::Migration
  def change
    add_column :nested_questions, :ident, :string, null: false
  end
end
