class ManuscriptManagersPolicy < ApplicationPolicy

  require_params :paper

  def can_manage_manuscript?
    super_admin? || can_manage_any_manuscript? || can_manage_this_manuscript?
  end

  alias_method :show?, :can_manage_manuscript?

  private

  def roles
    current_user.roles.where(journal: paper.journal)
  end

  def can_manage_any_manuscript?
    roles.merge(Role.can_view_all_manuscript_managers).exists?
  end

  def can_manage_this_manuscript?
    user_assigned_to_paper?(current_user, paper) &&
      journal_roles.merge(Role.can_view_assigned_manuscript_managers).exists?
  end

  def user_assigned_to_paper?(user, paper)
    (paper.tasks.assigned_to(user).exists? ||
      PaperRole.for_user(user).where(paper: paper).exists?)
  end

  def journal_roles
    current_user.roles.where(journal: paper.journal)
  end
end
