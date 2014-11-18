class PapersPolicy < ApplicationPolicy
  primary_resource :paper

  def connected_users
    paper.assigned_users
  end

  def show?
    can_view_paper?
  end

  def create?
    current_user.present?
  end

  def update?
    can_manage_paper?
  end

  def upload?
    can_view_paper?
  end

  def edit?
    can_view_paper?
  end

  def download?
    can_manage_paper?
  end

  def heartbeat?
    paper.locked_by_id == current_user.id
  end

  def toggle_editable?
    current_user.site_admin? || can_view_manuscript_manager?
  end

  def submit?
    can_manage_paper?
  end

  private

  def can_manage_paper?
    current_user.site_admin? || author? || paper_collaborator? || paper_admin? || paper_editor? || paper_reviewer?
  end

  def can_view_paper?
    can_manage_paper? || can_view_manuscript_manager?
  end

  PaperRole::ALL_ROLES.each do |role|
    define_method "paper_#{role}?" do
      paper.role_for(role: role, user: current_user).exists?
    end
  end

  def can_view_manuscript_manager?
    current_user.roles.where(journal_id: paper.journal).where(can_view_all_manuscript_managers: true).exists?
  end

  def author?
    author_of_paper? paper
  end
end
