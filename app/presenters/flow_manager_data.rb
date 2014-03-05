require 'ostruct'
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
    flow_map = [
      {'title' => 'Up for grabs', 'tasks' => unassigned_papers},
      {'title' => 'My Tasks',     'tasks' => incomplete_tasks},
      {'title' => 'My Papers',    'tasks' => paper_admin_tasks},
      {'title' => 'Done',         'tasks' => complete_tasks},
    ]
    flow_map.each {|flow| flow['empty_text'] = empty_text(flow['title']) }
      .select! {|flow| settings.flows.include? flow['title'] }
    flow_map.map {|flow| OpenStruct.new(flow) }
  end

  private
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

end
