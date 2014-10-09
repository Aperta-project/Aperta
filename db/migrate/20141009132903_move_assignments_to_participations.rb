class MoveAssignmentsToParticipations < ActiveRecord::Migration
  def up
    Task.where.not(assignee_id: nil).find_each do |task|
      unless task.participants.include? task.assignee
        task.participants << task.assignee
        task.update_attribute(:assignee, nil)
        CommentLookManager.sync_task(task)
      end
    end

    remove_column :tasks, :assignee_id
  end

  def down
    add_column :tasks, :assignee_id, :integer
  end
end
