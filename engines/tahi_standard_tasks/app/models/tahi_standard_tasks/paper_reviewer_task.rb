# coding: utf-8
module TahiStandardTasks
  class PaperReviewerTask < ::Task
    DEFAULT_TITLE = 'Invite Reviewers'
    DEFAULT_ROLE = 'editor'

    include Invitable

    def invitation_invited(invitation)
      PaperReviewerMailer.delay.notify_invited invitation_id: invitation.id
    end

    def invitation_accepted(invitation)
      ReviewerReportTaskCreator.new(originating_task: self, assignee_id: invitation.invitee_id).process
      ReviewerMailer.delay.reviewer_accepted(invite_reviewer_task_id: id, assigner_id: paper.academic_editor.try(:id), reviewer_id: invitation.try(:invitee_id))
    end

    def invitation_rejected(invitation)
      ReviewerMailer.delay.reviewer_declined(invite_reviewer_task_id: id, assigner_id: paper.academic_editor.try(:id), reviewer_id: invitation.try(:invitee_id))
    end

    def invitation_rescinded(invitation)
      PaperReviewerMailer.delay.notify_rescission(
        recipient_email: invitation.email,
        recipient_name: invitation.recipient_name,
        paper_id: invitation.paper.id
      )
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

    def invitation_template
      LetterTemplate.new(
        salutation: "Dear [REVIEWER NAME],",
        body: invitation_template_body
      )
    end

    private

    def invitation_template_body
      template = <<-TEXT.strip_heredoc
        You've been invited as a Reviewer on “%{manuscript_title}”, for %{journal_name}.

        The abstract is included below. We would ideally like to have reviews returned to us within 10 days. If you require additional time, please do let us know so that we may plan accordingly.

        Please only accept this invitation if you have no conflicts of interest. If in doubt, please feel free to contact us for advice. If you are unable to review this manuscript, we would appreciate suggestions of other potential reviewers.

        We look forward to hearing from you.

        Sincerely,
        %{journal_name} Team
      TEXT
      template % template_data
    end

    def template_data
      { manuscript_title: paper.display_title(sanitized: false),
        journal_name: paper.journal.name }
    end
  end
end
