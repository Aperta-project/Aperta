# APERTA-5579
class AddInvitationQueueIndices < ActiveRecord::Migration
  def change
    add_index :invitations, :invitation_queue_id
    add_index :invitations, :state
    add_index :invitations, :primary_id
  end
end
