class FlowSerializer < ActiveModel::Serializer
  attributes :id, :title, :empty_text
  has_many :lite_papers, embed: :ids, include: true, serializer: LitePaperSerializer
  has_many :tasks, embed: :ids, include: true, root: :card_thumbnails, serializer: CardThumbnailSerializer

  def tasks
    @tasks ||= flow_map[object.title]
  end

  def lite_papers
    Paper.joins(:tasks).includes(:paper_roles).where("tasks.id" => tasks).uniq
  end

  def cached_tasks
    @cached_tasks ||= Task.assigned_to(scoped_user).includes(:paper)
  end

  def incomplete_tasks
    cached_tasks.incomplete
  end

  def complete_tasks
    cached_tasks.completed
  end

  def paper_admin_tasks
    Task.joins(paper: :assigned_users)
      .includes(:paper)
      .merge(PaperRole.admins.for_user(scoped_user))
      .where(type: "StandardTasks::PaperAdminTask")
  end

  def unassigned_tasks
    Task.joins(paper: :journal)
      .includes(:paper)
      .incomplete.unassigned
      .where(type: "StandardTasks::PaperAdminTask")
      .where(journals: {id: scoped_user.roles.pluck(:journal_id).uniq })
  end

  def flow_map
    {
      'Up for grabs' => unassigned_tasks,
      'My tasks' => incomplete_tasks,
      'My papers' => paper_admin_tasks,
      'Done' => complete_tasks
    }
  end

  private

  def scoped_user
    scope.presence || options[:user]
  end
end
