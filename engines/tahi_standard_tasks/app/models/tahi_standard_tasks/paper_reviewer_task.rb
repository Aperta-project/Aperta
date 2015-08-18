module TahiStandardTasks
  class PaperReviewerTask < ::Task
    register_task default_title: "Invite Reviewers", default_role: "editor"

    include Invitable

    def invitation_invited(invitation)
      PaperReviewerMailer.delay.notify_invited invitation_id: invitation.id
    end

    def invitation_accepted(invitation)
      ReviewerReportTaskCreator.new(originating_task: self, assignee_id: invitation.invitee_id).process
      ReviewerMailer.delay.reviewer_accepted(invite_reviewer_task_id: id, assigner_id: paper.editor.try(:id), reviewer_id: invitation.try(:invitee_id))
    end

    def invitation_rejected(invitation)
      ReviewerMailer.delay.reviewer_declined(invite_reviewer_task_id: id, assigner_id: paper.editor.try(:id), reviewer_id: invitation.try(:invitee_id))
    end

    def invitation_rescinded(code:)
      PaperReviewerMailer.delay.notify_rescission(code: code)
    end

    def array_attributes
      super + [:reviewer_ids]
    end

    def self.permitted_attributes
      super + [{ reviewer_ids: [] }]
    end

    def update_responder
      TahiStandardTasks::UpdateResponders::PaperReviewerTask
    end

    def invitee_role
      'reviewer'
    end

    def invite_letter
      template = <<-TEXT.strip_heredoc
        Dear [REVIEWER NAME],

        You've been invited as a Reviewer on “%{manuscript_title}”, for %{journal_name}.

        The abstract is included below. We would ideally like to have reviews returned to us within 10 days. If you require additional time, please do let us know so that we may plan accordingly.

        Please only accept this invitation if you have no conflicts of interest. If in doubt, please feel free to contact us for advice. If you are unable to review this manuscript, we would appreciate suggestions of other potential reviewers.

        We look forward to hearing from you.

        Sincerely,
        %{journal_name} Team
      TEXT

      template % template_data
    end

    private

    def template_data
      { manuscript_title: paper.title,
        journal_name: paper.journal.name }
    end
  end
end
