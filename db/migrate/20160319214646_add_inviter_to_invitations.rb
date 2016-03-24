class AddInviterToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :inviter_id, :integer
  end
end
