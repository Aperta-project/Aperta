# TaskFactory is the sole class responsible for actually adding new Task
# instances to a paper
class TaskFactory
  attr_reader :task, :task_klass

  def self.create(task_klass, options = {})
    task = new(task_klass, options).save
    task.task_added_to_paper(task.paper)
    task
  end

  def initialize(task_klass, options = {})
    @task_klass = task_klass

    task_options = default_options
                  .merge(options)
                  .except(:creator, :notify)
    @task = task_klass.new(task_options)

    set_required_permissions
  end

  def save
    task.save!
    task
  end

  private

  def default_options
    HashWithIndifferentAccess.new(
      title: task_klass::DEFAULT_TITLE,
      card_version: task_klass.latest_card_version
    )
  end

  def set_required_permissions
    return if task.required_permissions.present?

    # custom card permissions have not been defined yet
    return if task.is_a?(CustomCardTask)

    task.required_permissions = task.journal_task_type.required_permissions
  end
end
