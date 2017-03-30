# don't need it
class RemovePaperForeignKeyFromAnswers < ActiveRecord::Migration
  def change
    remove_foreign_key :answers, column: :paper_id
  end
end
