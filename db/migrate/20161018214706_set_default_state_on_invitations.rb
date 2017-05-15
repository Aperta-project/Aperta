class SetDefaultStateOnInvitations < ActiveRecord::Migration
  def change
    change_column :invitations, :state, :string, default: "pending", null: false
  end
end
