class PapersPolicy < ApplicationPolicy
  primary_resource :paper

  def show?
    can_view_paper? paper
  end

  def create?
    current_user.present?
  end

  def update?
    can_view_paper? paper
  end

  def upload?
    can_view_paper? paper
  end

  def edit?
    can_view_paper? paper
  end

  def manage?
    current_user.site_admin? || can_view_manuscript_manager?(paper)
  end

  def download?
    can_view_paper? paper
  end

  def toggle_editable?
    current_user.site_admin? || can_view_manuscript_manager?(paper)
  end

  def snapshots?
    can_view_paper? paper
  end

  def submit?
    can_view_paper? paper
  end

  def withdraw?
    can_view_paper? paper
  end

  def reactivate?
    current_user.site_admin? || current_user.can?(:administer, paper.journal)
  end

  def workflow_activities?
    can_view_manuscript_manager? paper
  end

  def manuscript_activities?
    can_view_paper? paper
  end

  def versioned_texts?
    can_view_paper? paper
  end
end
