# Queues keeps track of and hold invitation-like objects
class CreateInviteQueues < ActiveRecord::Migration
  def change
    create_table :invite_queues do |t|
      t.string :queue_title
      t.integer :task_id
      t.integer :primary_id
      t.integer :decision_id
      t.boolean :main_queue, null: false
      t.timestamps
    end

    add_column :invitations, :invite_queue_id, :integer
  end
end
