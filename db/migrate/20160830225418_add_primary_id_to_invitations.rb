# primary_id refers to the "primary" invitation that an alternate is following
class AddPrimaryIdToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :primary_id, :integer
  end
end
