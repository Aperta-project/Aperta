class ManuscriptManagerPolicy < ApplicationPolicy

  require_params :paper

  def show?
    current_user.admin? || can_manage_any_manuscript || can_manage_this_manuscript
  end

  private

  def roles
    current_user.journal_roles.where(journal: paper.journal).joins(:role)
  end

  def can_manage_any_manuscript
    roles.where('roles.can_view_all_manuscript_managers' => true).exists?
  end

  def can_manage_this_manuscript
    paper.tasks.assigned_to(current_user).exists? &&
      roles.where('roles.can_view_assigned_manuscript_managers' => true).exists?
  end

end
