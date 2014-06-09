class PapersPolicy < ApplicationPolicy
  allow_params :paper

  def show?
    current_user.admin? || author? || paper_admin? || paper_editor? || paper_reviewer?
  end

  def edit?
    current_user.admin? || author? || paper_admin? || paper_editor? || paper_reviewer?
  end

  def create?
    current_user.present?
  end

  def update?
    current_user.admin? || author? || paper_admin? || paper_editor? || paper_reviewer?
  end

  def upload?
    current_user.admin? || author? || paper_admin? || paper_editor? || paper_reviewer?
  end

  def download?
    current_user.admin? || author? || paper_admin? || paper_editor? || paper_reviewer?
  end


  private

  def paper_editor?
    Paper.
      where(id: paper.id).
      joins(:paper_roles).
      where("paper_roles.user_id = ? AND paper_roles.editor = ?", current_user.id, true).
      present?
  end

  def paper_reviewer?
    Paper.
      where(id: paper.id).
      joins(:paper_roles).
      where("paper_roles.user_id = ? AND paper_roles.reviewer = ?", current_user.id, true).
      present?
  end

  def paper_admin?
    Paper.
      where(id: paper.id).
      joins(:paper_roles).
      where("paper_roles.user_id = ? AND paper_roles.admin = ?", current_user.id, true).
      present?
  end

  def author?
    current_user.submitted_papers.where(id: paper.id).present?
  end
end
