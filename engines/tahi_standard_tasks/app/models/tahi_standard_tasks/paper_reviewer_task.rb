module TahiStandardTasks
  class PaperReviewerTask < ::Task
    register_task default_title: "Invite Reviewers", default_role: "editor"

    include Invitable

    def invitation_invited(invitation)
      PaperReviewerMailer.delay.notify_invited invitation_id: invitation.id
    end

    def invitation_accepted(invitation)
      transaction do
        TaskRoleUpdater.new(self, invitation.invitee_id, PaperRole::REVIEWER).update
        task = TahiStandardTasks::ReviewerReportTask.create!(phase: reviewer_report_task_phase,
                                                             role: journal_task_type.role,
                                                             title: "Review by #{invitation.invitee.full_name}")
        ParticipationFactory.create(task, invitation.invitee)
      end
    end

    def invitation_rejected(invitation)
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

    private

    def reviewer_report_task_phase
      get_reviews_phase = paper.phases.where(name: 'Get Reviews').first
      get_reviews_phase || phase
    end
  end
end
