# Keeps tracks of state dates in preparation for automated queueing
class AddStateDatesToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :invited_at, :date
    add_column :invitations, :declined_at, :date
    add_column :invitations, :accepted_at, :date
  end
end
