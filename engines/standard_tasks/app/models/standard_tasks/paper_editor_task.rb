module StandardTasks
  class PaperEditorTask < Task

    register_task default_title: "Assign Editor", default_role: "admin"

    include Invitable

    def invitation_accepted(invitation)
      TaskRoleUpdater.new(self, invitation.invitee_id, PaperRole::EDITOR).update
    end

  end
end
