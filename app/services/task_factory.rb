class TaskFactory
  attr_reader :task, :task_klass, :creator, :notify

  def self.create(task_klass, options = {})
    task = new(task_klass, options).save
    task.task_added_to_paper(task.paper)
    task
  end

  def initialize(task_klass, options = {})
    @creator = options.delete(:creator)
    @notify = options.delete(:notify) { true }

    @task_klass = task_klass
    options = default_options.merge(options)
    @task = task_klass.new(options)
    set_required_permissions
  end

  def save
    task.save!
    task
  end

  private

  def default_options
    {
      title: task_klass::DEFAULT_TITLE,
    }
  end

  def set_required_permissions
    return if @task.required_permissions.present?
    @task.required_permissions = @task.journal_task_type.required_permissions
  end
end
