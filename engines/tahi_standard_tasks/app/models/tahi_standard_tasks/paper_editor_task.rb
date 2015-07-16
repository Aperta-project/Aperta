module TahiStandardTasks
  class PaperEditorTask < Task
    register_task default_title: "Invite Editor", default_role: "admin"

    include Invitable

    def invitation_invited(invitation)
      invitation.update! information: "Here are the authors on the paper: #{paper.authors_list}"
      PaperEditorMailer.delay.notify_invited({
        invitation_id: invitation.id
      })
    end

    def invitation_accepted(invitation)
      replace_editor_and_follow_tasks invitation
      follow_reviewer_reports invitation
    end

    def invitee_role
      'editor'
    end

    private

    def replace_editor_and_follow_tasks(invitation)
      TaskRoleUpdater.new(task: self,
                          assignee_id: invitation.invitee_id,
                          paper_role_name: PaperRole::EDITOR).update
    end

    def follow_reviewer_reports(invitation)
      paper.tasks.where(type: 'TahiStandardTasks::ReviewerReportTask').each do |task|
        ParticipationFactory.create(task: task, assignee: User.find(invitation.invitee_id))
      end
    end
  end
end
