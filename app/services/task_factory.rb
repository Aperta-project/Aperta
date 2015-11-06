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

  attr_reader :task, :task_klass, :creator, :notify

  def initialize(task_klass, options={})
    @creator = options.delete(:creator)
    @notify = options.delete(:notify) { true }

    @task_klass = task_klass
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
    # The ParticipationFactory will not sent a notification
    # if assigner and assignee are the same
    participation_params = { task: task, assignee: creator }
    participation_params.merge!(assigner: creator) if notify == false
    ParticipationFactory.create(participation_params)
  end
end
