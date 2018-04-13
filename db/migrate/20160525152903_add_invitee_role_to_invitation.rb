# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
