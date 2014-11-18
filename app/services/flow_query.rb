class FlowQuery
  attr_reader :user, :flow_title, :scope_to_journals

  def initialize(user, flow_title)
    @user = user
    @flow_title = flow_title
    @scope_to_journals = !user.site_admin?
  end

  def tasks
    @tasks ||= flow_map[flow_title]
  end

  def lite_papers
    @lite_papers ||= Paper.joins(:tasks).
      includes(:paper_roles).
      where("tasks.id" => tasks).
      uniq
  end

  private

  def flow_map
    {
      'Up for grabs' => unassigned_tasks,
      'My papers' => paper_admin_tasks_for_user,
      'My tasks' => assigned_tasks.incomplete,
      'Done' => assigned_tasks.completed
    }
  end

  def assigned_tasks
    base_query.assigned_to(user)
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
