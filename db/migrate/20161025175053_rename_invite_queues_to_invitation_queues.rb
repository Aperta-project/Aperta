# rename table to keep consistent naming
class RenameInviteQueuesToInvitationQueues < ActiveRecord::Migration
  def change
    rename_table :invite_queues, :invitation_queues
    rename_column :invitations, :invite_queue_id, :invitation_queue_id
  end
end
