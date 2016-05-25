# We don't need this anymore. Invitations should be linked directly to a user
# account via email address.
class RemoveCodeFromInvitations < ActiveRecord::Migration
  def change
    remove_column :invitations, :code, :string
  end
end
