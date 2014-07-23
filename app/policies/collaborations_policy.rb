class CollaborationsPolicy < ApplicationPolicy
  allow_params :paper

  def create?
    current_user.admin? || author? || paper_admin? || paper_editor? || paper_reviewer? || paper_collaborator?
  end

  def destroy?
    current_user.admin? || author? || paper_admin? || paper_editor? || paper_reviewer? || paper_collaborator?
  end

  private

  %w(editor reviewer admin collaborator).each do |role|
    define_method "paper_#{role}?" do
      paper.role_for(role: role, user: current_user).exists?
    end
  end

  def author?
    author_of_paper? paper
  end
end
