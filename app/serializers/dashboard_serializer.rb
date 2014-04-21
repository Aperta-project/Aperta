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
    # all tasks that i am assigned too
    # i may not have authored the paper
    direct_tasks = current_user.tasks.includes({paper: :message_tasks}, :assignee)
    # (direct_tasks + paper.message_tasks)
    direct_tasks
  end

  def task_paper

  end

end
