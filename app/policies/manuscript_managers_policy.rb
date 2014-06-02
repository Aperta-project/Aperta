class ManuscriptManagersPolicy < ApplicationPolicy

  require_params :paper

  def show?
    super_admin? || can_manage_any_manuscript? || can_manage_this_manuscript?
  end

  private

  def roles
    current_user.roles.where(journal: paper.journal)
  end

  def can_manage_any_manuscript?
    roles.merge(Role.can_view_all_manuscript_managers).exists?
  end

  def can_manage_this_manuscript?
    paper.tasks.assigned_to(current_user).exists? &&
    roles.merge(Role.can_view_assigned_manuscript_managers).exists?
  end

end
