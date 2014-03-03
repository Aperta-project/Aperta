class FlowManagerData

  def initialize(user)
    @user = user
  end

  def incomplete_tasks
    base_query(Task).assigned_to(@user).incomplete.group_by { |t| t.paper }.to_a
  end

  def complete_tasks
    base_query(Task).assigned_to(@user).completed.map do |task|
      [task.paper, [task]]
    end
  end

  def paper_admin_tasks
    base_query(PaperAdminTask).assigned_to(@user).map do |task|
      [task.paper, []]
    end
  end

  def unassigned_papers
    base_query(PaperAdminTask).includes(:journal).where(assignee_id: nil).map do |task|
      [task.paper, [task]] if User.admins_for(task.paper.journal).include? @user
    end.compact
  end

  def flows
    settings = @user.user_settings
    flow_map = {
      'Up for grabs' => unassigned_papers,
      'My Tasks' => incomplete_tasks,
      'My Papers' => paper_admin_tasks,
      'Done' => complete_tasks
    }
    @flows = settings.flows.map do |flow_title|
      [flow_title, flow_map[flow_title]]
    end
    # [["Up for grabs", unassigned_papers],
    #  ["My Tasks", incomplete_tasks],
    #  ["My Papers", paper_admin_tasks],
    #  ["Done", complete_tasks]]
  end

  private

  def base_query(task_type)
    task_type.joins(phase: {task_manager: :paper}).includes(:paper, {paper: :figures}, {paper: :declarations}, {paper: {journal: :journal_roles}})
  end

end
