class TaskFactory
  attr_reader :task, :task_klass, :creator, :notify

  def self.create(task_klass, options = {})
    new(task_klass, options).save
  end

  def initialize(task_klass, options = {})
    @creator = options.delete(:creator)
    @notify = options.delete(:notify) { true }

    @task_klass = task_klass
    options = default_options.merge(options)
    @task = task_klass.new(options)
    @task.set_required_permissions unless @task.required_permissions.present?
  end

  def save
    task.save!
    task
  end

  private

  def default_options
    {
      title: task_klass::DEFAULT_TITLE,
      old_role: task_klass::DEFAULT_ROLE
    }
  end
end
