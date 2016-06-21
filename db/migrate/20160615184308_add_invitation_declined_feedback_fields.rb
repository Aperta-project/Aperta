# Add new fields to invitation to ollect decline feedback
class AddInvitationDeclinedFeedbackFields < ActiveRecord::Migration
  def change
    add_column :invitations, :decline_reason, :text
    add_column :invitations, :reviewer_suggestions, :text
  end
end
