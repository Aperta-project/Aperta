class FlowSerializer < ActiveModel::Serializer
  attributes :id, :title, :empty_text
  has_many :lite_papers, embed: :ids, include: true, serializer: LitePaperSerializer
  has_many :tasks, embed: :ids, include: true, root: :card_thumbnails, serializer: CardThumbnailSerializer

  def tasks
    @tasks ||= flow_map[object.title]
  end

  def lite_papers
    @papers ||= tasks.flat_map(&:paper).uniq
  end

  def cached_tasks
    @cached_tasks ||= Task.assigned_to(current_user).includes(:paper)
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

  def unassigned_papers
    PaperAdminTask.where(assignee_id: nil).includes(:journal, :paper)
  end

  def flow_map
    {
      'Up for grabs' => unassigned_papers,
      'My tasks' => incomplete_tasks,
      'My papers' => paper_admin_tasks,
      'Done' => complete_tasks
    }
  end

end
