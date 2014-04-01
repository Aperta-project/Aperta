class FlowManagerData

  def initialize(user)
    @user = user
  end

  def incomplete_tasks
    base_query(Task).assigned_to(@user).incomplete.group_by { |t| t.paper }
  end

  def complete_tasks
    base_query(Task).assigned_to(@user).completed.map do |task|
      task.paper
    end
  end

  def paper_admin_tasks
    base_query(PaperAdminTask).assigned_to(@user).map do |task|
      task.paper
    end
  end

  def unassigned_papers
    base_query(PaperAdminTask).includes(:journal).where(assignee_id: nil).map do |task|
      task.paper if User.admins_for(task.paper.journal).include? @user
    end.compact
  end

  def flows
    @flows ||= [
      Flow.where(title: 'Up for grabs').first,
      Flow.where(title: 'My tasks').first,
      Flow.where(title: 'My papers').first,
      Flow.where(title: 'Done').first
    ].map {|f| f.papers = flow_map[f.title]; f }
  end

  private

  def flow_map
    {
      'Up for grabs' => unassigned_papers,
      'My tasks' => incomplete_tasks,
      'My papers' => paper_admin_tasks,
      'Done' => complete_tasks
    }
  end

  def base_query(task_type)
    task_type.joins(phase: {task_manager: :paper}).includes(:paper, {paper: :figures}, {paper: :declarations}, {paper: {journal: :journal_roles}})
  end
end
