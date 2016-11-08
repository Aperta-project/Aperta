# Queues keeps track of and hold invitation-like objects
class CreateInviteQueuesAgain < ActiveRecord::Migration
  def change
    create_table :invite_queues do |t|
      t.integer :task_id
      t.integer :decision_id
      t.timestamps
    end

    add_column :invitations, :invite_queue_id, :integer
  end
end
