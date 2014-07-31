module StandardTasks
  class PaperReviewerTask < ::Task
    def permitted_attributes
      super + [{ reviewer_ids: [] }]
    end

    title 'Assign Reviewers'
    role 'editor'

    def array_attributes
      [:reviewer_ids]
    end

    # TODO: Change this ASAP
    # hard-coded phase name needs to go away.
    # requires MMT changes
    def reviewer_ids=(user_ids)
      user_ids = user_ids.map(&:to_i)
      new_ids = user_ids - reviewer_ids
      old_ids = reviewer_ids - user_ids
      new_ids.each do |id|
        PaperRole.reviewers_for(paper).where(user_id: id).create!
        ReviewerReportTask.create! assignee_id: id, phase: reviewer_report_task_phase
      end
      PaperRole.reviewers_for(paper).where(user_id: old_ids).destroy_all
      paper.tasks.where(type: ReviewerReportTask, assignee_id: old_ids).destroy_all
      user_ids
    end

    def reviewer_ids
      reviewers.pluck(:user_id)
    end

    def journal_reviewers
      journal.reviewers
    end

    def assignees
      journal.editors
    end

    def reviewers
      paper.reviewers
    end

    def update_responder
      StandardTasks::UpdateResponders::PaperReviewerTask
    end

    private

    def reviewer_report_task_phase
      get_reviews_phase = paper.phases.where(name: 'Get Reviews').first
      get_reviews_phase || phase
    end
  end
end
