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

  %w(editor reviewer admin).each do |role|
    define_method "paper_#{role}?" do
      paper.role_for(role: role, user: current_user).present?
    end
  end

  def author?
    author_of_paper? paper
  end
end
