# Position is needed for drag and drop reordering of invitations for queuing
class AddPositionToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :position, :integer
  end
end
