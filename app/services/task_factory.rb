class TaskFactory

  def self.create(task_klass, options={})
    new(task_klass, options).save
  end

  def save
    task.save!
    add_creator_as_participant
    task
  end

  private

  attr_reader :task, :task_klass, :creator

  def initialize(task_klass, options={})
    @task_klass = task_klass
    @creator = options.delete(:creator)
    options = default_options.merge(options)
    @task = task_klass.constantize.new(options)
  end

  def default_options
    {
      title: TaskType.types[task_klass].fetch(:default_title),
      role: TaskType.types[task_klass].fetch(:default_role)
    }
  end

  def add_creator_as_participant
    return unless task.submission_task? && creator
    ParticipationFactory.create(task: task, assignee: creator)
  end
end
