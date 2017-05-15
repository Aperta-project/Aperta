class AddUniqueConstraintToInvitationTokens < ActiveRecord::Migration
  def change
    change_column_null :invitations, :token, false
    add_index :invitations, :token, unique: true
  end
end
