class PaperReviewerTask < Task
  PERMITTED_ATTRIBUTES = [{ paper_roles: [] }]

  title 'Assign Reviewer'
  role 'editor'

  def paper_roles
    PaperRole.where(paper: phase.task_manager.paper, reviewer: true).pluck :user_id
  end

  def paper_roles=(user_ids)
    existing_ids = PaperRole.where(paper: paper, reviewer: true).map(&:user_id).map &:to_s
    current_ids = user_ids.reject!(&:empty?)
    new_ids = current_ids - existing_ids
    old_ids = existing_ids - current_ids
    new_ids.each do |id|
      PaperRole.create(paper: phase.task_manager.paper, reviewer: true, user_id: id)
    end
    PaperRole.where(paper: phase.task_manager.paper, reviewer: true, user_id: old_ids).destroy_all
  end
end
