module TaskAccessCriteria
  private

  def paper
    task.paper
  end

  def journal_roles
    current_user.roles.where(journal_id: task.journal.id)
  end

  def task_owner?
    task.assignee_id == current_user.id
  end

  def metadata_task_collaborator?
    task.is_metadata? && task.paper.collaborators.exists?(current_user)
  end

  def can_view_all_manuscript_managers_for_journal?
    journal_roles.merge(Role.can_view_all_manuscript_managers).exists?
  end

  def can_view_manuscript_manager_for_paper?
    (paper.tasks.assigned_to(current_user).exists? ||
    PaperRole.for_user(current_user).where(paper: paper).exists?) &&
    journal_roles.merge(Role.can_view_assigned_manuscript_managers).exists?
  end

  def task_participant?
    task.participants.exists?(current_user)
  end

  def allowed_manuscript_information_task?
    task.manuscript_information_task? && has_paper_role?
  end

  def allowed_reviewer_task?
    task.role == 'reviewer' && paper.role_for(role: ['editor', 'reviewer'], user: current_user).exists?
  end

  def has_paper_role?
    paper.assigned_users.exists?(current_user)
  end
end
