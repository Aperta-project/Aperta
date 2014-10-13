class MoveAssignmentsToParticipations < ActiveRecord::Migration
  def up
    remove_column :tasks, :assignee_id
  end

  def down
    add_column :tasks, :assignee_id, :integer
  end
end
