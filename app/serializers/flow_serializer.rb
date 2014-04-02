class FlowSerializer < ActiveModel::Serializer
  attributes :id, :title, :empty_text
  has_many :papers, embed: :ids, include: true, serializer: FlowPaperSerializer
  has_many :tasks, embed: :ids, include: true, polymorphic: true

  def tasks
    @tasks ||= flow_map[object.title]
  end

  def papers
    @papers ||= tasks.flat_map(&:paper).uniq
  end

  def cached_tasks
    @cached_tasks ||= Task.assigned_to(current_user)
  end

  def incomplete_tasks
    cached_tasks.incomplete
  end

  def complete_tasks
    cached_tasks.completed
  end

  def paper_admin_tasks
    cached_tasks.where(type: "PaperAdminTask")
  end

  # simplify this and then remove the base_query
  def unassigned_papers
    base_query(PaperAdminTask).includes(:journal).where(assignee_id: nil)
  end

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
