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

    def invitation_rescinded(paper_id:, invitee_id:)
      PaperReviewerMailer.delay.notify_rescission paper_id: paper_id, invitee_id: invitee_id
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

        I would love to invite you to be a reviewer for %{manuscript_title}.  View the manuscript on Tahi and let me know if you accept or reject this offer.

        Thank you,
        [YOUR NAME]
        %{journal_name}
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
