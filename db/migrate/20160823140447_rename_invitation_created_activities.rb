# Invitations are no longer automatically sent when they're created as of APERTA-5372
class RenameInvitationCreatedActivities < ActiveRecord::Migration
  def up
    execute "UPDATE activities SET activity_key = 'invitation.sent' WHERE activity_key = 'invitation.created'"
  end

  def down
    execute "UPDATE activities SET activity_key = 'invitation.created' WHERE activity_key = 'invitation.sent'"
  end
end
