class RemoveDecisionLetterFromPaper < ActiveRecord::Migration
  def change
    remove_column :papers, :decision_letter
  end
end
