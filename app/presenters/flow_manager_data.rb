class FlowManagerData

  def initialize(user)
    @user = user
  end

  def incomplete_tasks
    normalize_paper(base_query(Task).assigned_to(@user).incomplete.group_by { |t| t.paper })
  end

  def complete_tasks
    normalize_paper(base_query(Task).assigned_to(@user).completed.map do |task|
      [task.paper, [task]]
    end)
  end

  def paper_admin_tasks
    normalize_paper(base_query(PaperAdminTask).assigned_to(@user).map do |task|
      [task.paper, []]
    end)
  end

  def unassigned_papers
    normalize_paper(base_query(PaperAdminTask).includes(:journal).where(assignee_id: nil).map do |task|
      [task.paper, [task]] if User.admins_for(task.paper.journal).include? @user
    end.compact)
  end

  def flows
    @user.user_settings.flows.inject(Array.new) { |acc, title|
      acc << flow_map.detect { |flow| title == flow['title'] }
    }
  end

  private

  def flow_map
    [
      {'title' => 'Up for grabs', 'papers' => unassigned_papers},
      {'title' => 'My Tasks',     'papers' => incomplete_tasks},
      {'title' => 'My Papers',    'papers' => paper_admin_tasks},
      {'title' => 'Done',         'papers' => complete_tasks},
    ].each {|flow| flow['empty_text'] = empty_text(flow['title']) }
  end

  def empty_text key
    {
      'up for grabs' => "Right now, there are no papers for you to grab.",
      'my tasks'     => "You don't have any tasks right now.",
      'my papers'    => "You aren't on any papers right now.",
      'done'         => "There is no recent activity to report."
    }[key.downcase]
  end

  def base_query(task_type)
    task_type.joins(phase: {task_manager: :paper}).includes(:paper, {paper: :figures}, {paper: :declarations}, {paper: {journal: :journal_roles}})
  end

  def normalize_paper(paper_with_tasks)
    paper_with_tasks.map do |(paper, tasks)|
      {paper_title: paper.display_title, paper_id: paper.id, task_ids: tasks.map(&:id)}
    end
  end

end
