class PaperReviewerTask < Task
  PERMITTED_ATTRIBUTES = [{ paper_role_attributes: [:user_id] }]

  title 'Assign Reviewer'
  role 'editor'

  def paper_role
    PaperRole.where(paper: phase.task_manager.paper, reviewer: true).first_or_initialize
  end

  def paper_role_attributes=(attributes)
    paper_role.update attributes
  end
end
