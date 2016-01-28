class TaskFactory
  attr_reader :task, :task_klass, :creator, :notify

  def self.create(task_klass, options={})
    new(task_klass, options).save
  end

  def initialize(task_klass, options={})
    @creator = options.delete(:creator)
    @notify = options.delete(:notify) { true }

    @task_klass = task_klass
    options = default_options.merge(options)
    @task = task_klass.constantize.new(options)
  end

  def save
    task.save!
    add_creator_as_participant
    task
  end

  private

  def default_options
    # Temporary fix for register tasks not being called on reload
    unless TaskType.types[task_klass]
      eval "#{task_klass.constantize}.register_task"
    end

    {
      title: TaskType.types[task_klass].fetch(:default_title),
      old_role: TaskType.types[task_klass].fetch(:default_role)
    }
  end

  def add_creator_as_participant
    return unless task.submission_task? && creator
    ParticipationFactory.create(task: task, assignee: creator, notify: notify)
  end
end
