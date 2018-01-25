class AddDueInColumnToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :due_in, :integer
  end
end
