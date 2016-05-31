# This migration adds invitee_role to the invitations table and fills in the
# role based on the task it is associated with. 
class AddInviteeRoleToInvitation < ActiveRecord::Migration
  ACADEMIC_EDITOR_ROLE = 'Academic Editor'
  REVIEWER_ROLE = 'Reviewer'

  def up
    add_column :invitations, :invitee_role, :string

    execute <<-SQL
      UPDATE invitations
      SET invitee_role = '#{ACADEMIC_EDITOR_ROLE}'
      FROM tasks
      WHERE
        tasks.id=invitations.task_id AND
        tasks.type='TahiStandardTasks::PaperEditorTask'
    SQL

    execute <<-SQL
      UPDATE invitations
      SET invitee_role = '#{REVIEWER_ROLE}'
      FROM tasks
      WHERE
        tasks.id=invitations.task_id AND
        tasks.type='TahiStandardTasks::PaperReviewerTask'
    SQL

    change_column :invitations, :invitee_role, :string, null: false
  end

  def down
    remove_column :invitations, :invitee_role
  end
end
