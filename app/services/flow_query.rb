class FlowQuery
  attr_reader :user, :scope_to_journals

  def initialize(user, role_flow)
    @user = user
    @role_flow = role_flow
    @scope_to_journals = !user.site_admin?
  end

  def tasks
    call((role_flow.query << ":user").join("."))
  end

  def lite_papers
    @lite_papers ||= Paper.joins(:tasks).
      includes(:paper_roles).
      where("tasks.id" => tasks).
      uniq
  end

  private

  def user
    where('task.user_id' => user)
  end

  def assigned
    assigned_to(user)
  end

  def paper_admin_tasks_for_user
    admin_tasks.
      joins(paper: :assigned_users).
      merge(PaperRole.admins.for_user(user))
  end

  def unassigned_tasks
    scope_to_journals ? unassigned_tasks_for_journals : all_unassigned_tasks
  end

  def unassigned_tasks_for_journals
    all_unassigned_tasks.
      joins(paper: :journal).
      where(journals: { id: attached_journal_ids })
  end

  def all_unassigned_tasks
    admin_tasks.incomplete.unassigned
  end

  def admin_tasks
    base_query.where(type: "StandardTasks::PaperAdminTask")
  end

  def base_query
    Task.includes(:paper)
  end

  def attached_journal_ids
    @attached_journal_ids ||= user.roles.pluck(:journal_id).uniq
  end
end
