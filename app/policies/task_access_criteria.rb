module TaskAccessCriteria
  private

  def paper
    task.paper
  end

  def journal
    task.paper.journal
  end

  def journal_roles
    current_user.old_roles.where(journal: journal)
  end

  # authorizations used by policies
  def authorized_to_modify_task?
    current_user.site_admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
      allowed_submission_task? || submission_task_collaborator? || allowed_reviewer_task? || task_participant?
  end

  def authorized_to_create_task?
    current_user.site_admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end

  # criteria used by this mixin
  def submission_task_collaborator?
    task.submission_task? && paper.collaborators.exists?(current_user.id)
  end

  def can_view_all_manuscript_managers_for_journal?
    journal_roles.merge(OldRole.can_view_all_manuscript_managers).exists?
  end

  def can_view_manuscript_manager_for_paper?
    participations_on_tasks_for_user = Participation.where(
      task_id: paper.task_ids, user_id: current_user
    )

    (
      participations_on_tasks_for_user.exists? ||
      PaperRole.for_user(current_user).where(paper: paper).exists?
    ) &&
    journal_roles.merge(OldRole.can_view_assigned_manuscript_managers).exists?
  end

  def task_participant?
    task.participants.exists?(current_user.id)
  end

  def allowed_submission_task?
    task.submission_task? && has_paper_role?
  end

  def allowed_reviewer_task?
    task.old_role == 'reviewer' && paper.role_for(old_role: ['editor', 'reviewer'], user: current_user).exists?
  end

  def has_paper_role?
    paper.assigned_users.exists?(current_user.id)
  end
end
