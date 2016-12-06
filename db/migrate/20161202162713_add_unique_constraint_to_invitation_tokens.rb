class AddUniqueConstraintToInvitationTokens < ActiveRecord::Migration
  def change
    add_index :invitations, :token, unique: true
  end
end
