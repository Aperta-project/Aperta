class PapersPolicy < ApplicationPolicy
  allow_params :paper

  def show?
    current_user.site_admin? || author? || paper_collaborator? || paper_admin? || paper_editor? || paper_reviewer? || can_view_manuscript_manager?
  end

  def edit?
    current_user.site_admin? || author? || paper_collaborator? || paper_admin? || paper_editor? || paper_reviewer?
  end

  def create?
    current_user.present?
  end

  def update?
    current_user.site_admin? || author? || paper_collaborator? || paper_admin? || paper_editor? || paper_reviewer?
  end

  def upload?
    current_user.site_admin? || author? || paper_collaborator? || paper_admin? || paper_editor? || paper_reviewer? || can_view_manuscript_manager?
  end

  def download?
    current_user.site_admin? || author? || paper_collaborator? || paper_admin? || paper_editor? || paper_reviewer?
  end

  def heartbeat?
    paper.locked_by_id == current_user.id
  end

  def toggle_editable?
    current_user.site_admin? || can_view_manuscript_manager?
  end

  def submit?
    update?
  end

  private

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
