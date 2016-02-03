class ManuscriptManagersPolicy < ApplicationPolicy

  require_params :paper

  def can_manage_manuscript?
    super_admin? ||
      current_user.can?(:manage_workflow, paper) ||
      can_manage_all_manuscripts? ||
      can_manage_this_manuscript?
  end

  alias_method :show?, :can_manage_manuscript?

  private

  def old_roles
    current_user.old_roles.where(journal: paper.journal)
  end

  def can_manage_all_manuscripts?
    old_roles.merge(OldRole.can_view_all_manuscript_managers).exists?
  end

  def can_manage_this_manuscript?
    user_assigned_to_paper?(current_user, paper) &&
      journal_roles.merge(OldRole.can_view_assigned_manuscript_managers).exists?
  end

  def user_assigned_to_paper?(user, paper)
    paper.participants.include?(user) ||
    Participation.where(task_id: paper.task_ids, user_id: current_user).exists? ||
      PaperRole.for_user(user).where(paper: paper).exists?
  end

  def journal_roles
    current_user.old_roles.where(journal: paper.journal)
  end
end
