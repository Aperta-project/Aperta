class DashboardSerializer < ActiveModel::Serializer
  attribute :id
  has_one :user, embed: :id, include: true
  has_many :submissions, embed: :ids, include: true, root: 'papers'
  has_many :assigned_tasks, embed: :ids, polymorphic: true, include: true, root: 'tasks'

  def id
    1
  end

  def user
    current_user
  end

  def submissions
    # all the papers i have submitted
    current_user.papers.includes(task_manager: :phases)
  end

  def assigned_tasks
    # all the tasks I have been associated with
    (current_user.tasks + current_user.papers.flat_map(&:message_tasks)).uniq
  end

  def task_paper
    # perhaps add all the papers from assigned tasks
  end

end
