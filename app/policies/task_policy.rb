class TaskPolicy
  def initialize(paper, user)
    @paper = paper
    @user = user
  end

  def tasks
    if paper.editor == user
      assigned_tasks + reviewer_tasks
    else
      assigned_tasks
    end
  end

  private
  attr_reader :user, :paper

  def phase_ids
    paper.task_manager.phase_ids
  end

  def assigned_tasks
    user.tasks.where(phase_id: phase_ids)
  end

  def reviewer_tasks
    Task.where(phase_id: phase_ids, role: 'reviewer')
  end
end
