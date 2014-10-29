module StandardTasks
  class PaperReviewerTask < ::Task
    register_task default_title: "Assign Reviewers", default_role: "editor"

    def array_attributes
      super + [:reviewer_ids]
    end

    def permitted_attributes
      super + [{ reviewer_ids: [] }]
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
      StandardTasks::UpdateResponders::PaperReviewerTask
    end

    private

    def add_reviewer(user)
      transaction do
        PaperRole.reviewers_for(paper).where(user: user).create!
        task = StandardTasks::ReviewerReportTask.create!(phase: reviewer_report_task_phase,
                                                         role: journal_task_type.role,
                                                         title: "Review by #{user.full_name}")
        ParticipationFactory.create(task, user)
      end
    end

    # TODO: remove need for hardcoded phase name across the application
    def reviewer_report_task_phase
      get_reviews_phase = paper.phases.where(name: 'Get Reviews').first
      get_reviews_phase || phase
    end
  end
end
