class PaperReviewerTask < Task
  PERMITTED_ATTRIBUTES = [{ paper_roles: [] }]

  title 'Assign Reviewer'
  role 'editor'

  def paper_roles
    PaperRole.where(paper: phase.task_manager.paper, reviewer: true)
  end

  def paper_roles=(attributes)
    binding.pry
    existing_ids = paper_roles.map(&:user_id).map &:to_s
    current_ids = attributes[:user_id]
    new_ids = current_ids - existing_ids
    old_ids = existing_ids - current_ids
    new_ids.each do |id|
      PaperRole.create(paper: phase.task_manager.paper, reviewer: true, user_id: id)
    end
    PaperRole.where(paper: phase.task_manager.paper, reviewer: true, user_id: old_ids).destroy_all
  end
end
