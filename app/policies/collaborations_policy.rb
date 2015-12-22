class CollaborationsPolicy < ApplicationPolicy
  require_params :paper

  def create?
    current_user.site_admin? || author? || paper_collaborator? || paper_admin? || paper_editor? || paper_reviewer?
  end

  def destroy?
    current_user.site_admin? || author? || paper_collaborator? || paper_admin? || paper_editor? || paper_reviewer?
  end

  private

  %w(editor reviewer admin collaborator).each do |old_role|
    define_method "paper_#{old_role}?" do
      paper.role_for(old_role: old_role, user: current_user).exists?
    end
  end

  def author?
    author_of_paper? paper
  end
end
