class PapersPolicy < ApplicationPolicy
  primary_resource :paper

  def show?
    can_view_paper?
  end

  def create?
    current_user.present?
  end

  def update?
    can_view_paper?
  end

  def upload?
    can_view_paper?
  end

  def edit?
    can_view_paper?
  end

  def manage?
    current_user.site_admin? || can_view_manuscript_manager?
  end

  def download?
    can_view_paper?
  end

  def heartbeat?
    paper.locked_by_id == current_user.id
  end

  def toggle_editable?
    current_user.site_admin? || can_view_manuscript_manager?
  end

  def submit?
    can_view_paper?
  end

  def withdraw?
    can_view_paper?
  end

  def reactivate?
    current_user.site_admin? || current_user.journal_admin?(journal: paper.journal)
  end

  def workflow_activities?
    can_view_manuscript_manager?
  end

  def manuscript_activities?
    can_view_paper?
  end

  private

  def can_view_paper?
    current_user.site_admin? || paper.assigned_users.where(id: current_user.id).exists? || can_view_manuscript_manager?
  end

  PaperRole::ALL_ROLES.each do |role|
    define_method "paper_#{role}?" do
      paper.role_for(role: role, user: current_user).exists?
    end
  end

  def can_view_manuscript_manager?
    current_user.site_admin? || current_user.roles.where(journal_id: paper.journal).
      where("can_view_assigned_manuscript_managers = ? OR can_view_all_manuscript_managers = ?", true, true).
      exists?
  end

  def author?
    author_of_paper? paper
  end
end
