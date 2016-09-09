# Keeps tracks of state dates in preparation for automated queueing
class AddStateDatesToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :invited_at, :datetime
    add_column :invitations, :declined_at, :datetime
    add_column :invitations, :accepted_at, :datetime
    add_column :invitations, :rescinded_at, :datetime
  end
end
