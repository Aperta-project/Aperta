class PaperReviewerTask < Task
  PERMITTED_ATTRIBUTES = [{ paper_roles: [] }]

  title 'Assign Reviewers'
  role 'editor'

  def paper_roles
    PaperRole.where(paper: phase.task_manager.paper, reviewer: true).pluck :user_id
  end

  def paper_roles=(user_ids)
    new_ids = user_ids - existing_user_ids
    old_ids = existing_user_ids - user_ids
    phase = paper.task_manager.phases.where(name: 'Get Reviews').first
    new_ids.reject(&:empty?).each do |id|
      PaperRole.reviewers_for(paper).where(user_id: id).create!
      ReviewerReportTask.create! assignee_id: id, phase: phase
    end
    PaperRole.reviewers_for(paper).where(user_id: old_ids).destroy_all
    ReviewerReportTask.where(assignee_id: old_ids, phase: phase).destroy_all
  end

  private

  def existing_user_ids
    PaperRole.reviewers_for(paper).map { |paper_role| paper_role.user_id.to_s }
  end
end
