class DashboardSerializer < ActiveModel::Serializer
  attribute :id
  has_one :user, embed: :id, include: true
  has_many :submissions, embed: :ids, include: true, root: :lite_papers, serializer: LitePaperSerializer
  has_many :assigned_tasks, embed: :ids, include: true, root: :card_thumbnails, serializer: CardThumbnailSerializer
  has_many :administered_journals

  def id
    1
  end

  def user
    @user ||= current_user
  end

  def administered_journals
    user.administered_journals
  end

  def submissions
    # all the papers i have submitted
    @submissions ||= current_user.submitted_papers
  end

  def assigned_tasks
    # all the tasks I have been associated with
    return @assigned_tasks if @assigned_tasks
    message_tasks = MessageTask.joins(:paper).where('papers.id' => current_user.submitted_papers.pluck(:id)).includes(:assignee, :paper)
    user_tasks = Task.assigned_to(current_user).where.not(type: 'MessageTask').includes(:assignee, :paper)
    @assigned_tasks = (user_tasks + message_tasks)
  end
end
