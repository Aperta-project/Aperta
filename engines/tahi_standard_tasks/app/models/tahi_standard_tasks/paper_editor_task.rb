module TahiStandardTasks
  class PaperEditorTask < Task
    register_task default_title: "Invite Editor", default_role: "admin"

    include Invitable

    def invitation_invited(invitation)
      if paper.authors_list.present?
        invitation.update! information: "Here are the authors on the paper:\n\n#{paper.authors_list}"
      end
      PaperEditorMailer.delay.notify_invited({
        invitation_id: invitation.id
      })
    end

    def invitation_accepted(invitation)
      replace_editor_and_follow_tasks invitation
      follow_reviewer_reports invitation
      follow_reviewer_recommendations invitation
      PaperAdminMailer.delay.notify_admin_of_editor_invite_accepted(
        paper_id:  invitation.paper.id,
        editor_id: invitation.invitee.id
      )
    end

    def invitee_role
      Role::ACADEMIC_EDITOR_ROLE
    end

    def invite_letter
      template = <<-TEXT.strip_heredoc
        Dear [EDITOR NAME],

        I would love to invite you to be an editor for %{manuscript_title}.  View the manuscript on Tahi and let me know if you accept or reject this offer.

        Thank you,
        [YOUR NAME]
        %{journal_name}

      TEXT

      template % template_date
    end

    private

    def template_date
      { manuscript_title: paper.display_title(sanitized: false),
        journal_name: paper.journal.name }
    end

    def replace_editor_and_follow_tasks(invitation)
      user = User.find(invitation.invitee_id)
      ParticipationFactory.create(task: self, assignee: user)
      paper.assignments.where(user: user, role: Role.editor)
        .first_or_create!
    end

    def follow_reviewer_reports(invitation)
      paper.tasks.where(type: 'TahiStandardTasks::ReviewerReportTask').each do |task|
        ParticipationFactory.create(task: task, assignee: User.find(invitation.invitee_id))
      end
    end

    def follow_reviewer_recommendations(invitation)
      paper.tasks.where(type: 'TahiStandardTasks::ReviewerRecommendationsTask').each do |task|
        ParticipationFactory.create(task: task, assignee: User.find(invitation.invitee_id))
      end
    end
  end
end
