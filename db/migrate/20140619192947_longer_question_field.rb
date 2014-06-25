class LongerQuestionField < ActiveRecord::Migration
  def up
    change_column :questions, :question, :text
    change_column :questions, :answer, :text
  end

  def down
    change_column :questions, :question, :string
    change_column :questions, :answer, :string
  end
end
