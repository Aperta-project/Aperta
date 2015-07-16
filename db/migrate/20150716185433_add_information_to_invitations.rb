class AddInformationToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :information, :string
  end
end
