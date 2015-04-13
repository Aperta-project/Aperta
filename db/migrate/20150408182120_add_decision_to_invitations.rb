class AddDecisionToInvitations < ActiveRecord::Migration
  def change
    add_reference :invitations, :decision, index: true
  end
end
