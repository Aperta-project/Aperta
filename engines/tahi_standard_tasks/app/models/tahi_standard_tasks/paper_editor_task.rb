module TahiStandardTasks
  class PaperEditorTask < Task
    register_task default_title: "Invite Editor", default_role: "admin"

    include Invitable

    def invitation_invited(invitation)
      PaperEditorMailer.delay.notify_invited({
        invitation_id: invitation.id
      })
    end

    def invitation_accepted(invitation)
      TaskRoleUpdater.new(task: self, assignee_id: invitation.invitee_id, paper_role_name: PaperRole::EDITOR).update
    end

    def invitee_role
      'editor'
    end
  end
end
