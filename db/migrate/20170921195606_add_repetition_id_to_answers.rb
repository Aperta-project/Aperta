class AddRepetitionIdToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :repetition_id, :integer
  end
end
