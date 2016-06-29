class AddDecidedToDecisions < ActiveRecord::Migration
  def change
    add_column :decisions, :decided, :boolean, default: false

    decided_papers =
      Paper.joins("INNER JOIN tasks AS decision_tasks ON decision_tasks.paper_id=papers.id AND decision_tasks.type='#{TahiStandardTasks::RegisterDecisionTask.sti_name}'")
           .where(decision_tasks: { completed: true })
    decided_papers.each do |paper|
      paper.decisions.last.update_column(:decided, true)
    end
  end

  def down
    remove_column :decisions, :decided
  end
end
