class TaskTemplatesPolicy < ApplicationPolicy
  require_params :task_template

  def show?
    can_administer_journal? journal
  end

  def create?
    can_administer_journal? journal
  end

  def update?
    can_administer_journal? journal
  end

  def destroy?
    can_administer_journal? journal
  end

  private

  def journal
    task_template.manuscript_manager_template.journal
  end
end
