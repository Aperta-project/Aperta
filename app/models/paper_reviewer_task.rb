class PaperReviewerTask < Task
  PERMITTED_ATTRIBUTES = [{ reviewer_ids: [] }]

  title 'Assign Reviewers'
  role 'editor'

  def self.array_attributes
    [:reviewer_ids]
  end

  def reviewer_ids=(user_ids)
    user_ids = user_ids.map(&:to_i)
    new_ids = user_ids - reviewer_ids
    old_ids = reviewer_ids - user_ids
    phase = paper.task_manager.phases.where(name: 'Get Reviews').first
    new_ids.each do |id|
      PaperRole.reviewers_for(paper).where(user_id: id).create!
      ReviewerReportTask.create! assignee_id: id, phase: phase
    end
    PaperRole.reviewers_for(paper).where(user_id: old_ids).destroy_all
    ReviewerReportTask.where(assignee_id: old_ids, phase: phase).destroy_all
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
    UpdateResponders::PaperReviewerTask
  end
end
