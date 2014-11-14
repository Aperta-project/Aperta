class FlowQuery
  attr_reader :user, :flow_title, :scope_to_journals

  def initialize(user, flow_title, scope_to_journals=false)
    @user = user
    @flow_title = flow_title
    @scope_to_journals = scope_to_journals
  end

  def tasks
    @tasks ||= flow_map[flow_title]
  end

  def lite_papers
    @lite_papers ||= Paper.joins(:tasks).includes(:paper_roles).where("tasks.id" => tasks).uniq
  end

  def assigned_tasks
    Task.assigned_to(user).includes(:paper)
  end

  def paper_admin_tasks_for_user
    Task.joins(paper: :assigned_users)
      .includes(:paper)
      .merge(PaperRole.admins.for_user(user))
      .where(type: "StandardTasks::PaperAdminTask")
  end

  def unassigned_tasks
    scope_to_journals ? unassigned_tasks_for_journals : all_unassigned_tasks
  end

  def unassigned_tasks_for_journals
    Task.joins(paper: :journal)
      .includes(:paper)
      .incomplete.unassigned
      .where(type: "StandardTasks::PaperAdminTask")
      .where(journals: { id: attached_journal_ids })
  end

  def all_unassigned_tasks
    Task.joins(:paper)
      .includes(:paper)
      .incomplete.unassigned
      .where(type: "StandardTasks::PaperAdminTask")
  end

  def attached_journal_ids
    @ids ||= user.roles.pluck(:journal_id).uniq 
  end

  def task_includes_paper
    Task.includes(:paper)
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
end
