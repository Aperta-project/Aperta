module TahiStandardTasks
  class PaperReviewerTask < ::Task
    def self.permitted_attributes
      super + [{ reviewer_ids: [] }]
    end

    register_task default_title: "Invite Reviewers", default_role: "reviewer"

    include Invitable

    def invitation_invited(invitation)
      PaperReviewerMailer.delay.notify_invited({
        invitation_id: invitation.id
      })
    end

    def invitation_accepted(invitation)
      TaskRoleUpdater.new(self, invitation.invitee_id, PaperRole::REVIEWER).update
    end

    def invitation_rejected(invitation)
    end

    def invitation_rescinded(paper_id:, invitee_id:)
      PaperReviewerMailer.delay.notify_rescission paper_id: paper_id, invitee_id: invitee_id
    end

    def array_attributes
      super + [:reviewer_ids]
    end

    def reviewer_ids=(user_ids)
      differences = Array.compare(paper.reviewers.pluck(:user_id), user_ids.map(&:to_i))
      differences[:added].each do |id|
        add_reviewer(User.find(id))
      end
      PaperRole.reviewers_for(paper).where(user_id: differences[:removed]).destroy_all
      differences[:added]
    end

    def update_responder
      TahiStandardTasks::UpdateResponders::PaperReviewerTask
    end

    private

    def add_reviewer(user)
      transaction do
        PaperRole.reviewers_for(paper).where(user: user).create!
        task = TahiStandardTasks::ReviewerReportTask.create!(phase: reviewer_report_task_phase,
                                                         role: journal_task_type.role,
                                                         title: "Review by #{user.full_name}")
        ParticipationFactory.create(task, user)
        UserMailer.delay.add_reviewer(user.id, paper.id)
      end
    end

    # TODO: remove need for hardcoded phase name across the application
    def reviewer_report_task_phase
      get_reviews_phase = paper.phases.where(name: 'Get Reviews').first
      get_reviews_phase || phase
    end
  end
end
