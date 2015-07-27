# This migration comes from tahi_assess (originally 20150721174726)
class AddTaskIdToEditorialDecision < ActiveRecord::Migration
  def change
    add_column :tahi_assess_editorial_decisions, :editorial_decision_task_id, :integer, index: true
  end
end
