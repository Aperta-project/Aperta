class AddDecisionToQuestions < ActiveRecord::Migration
  def change
    add_reference :questions, :decision, index: true
    add_foreign_key :questions, :decisions
  end
end
