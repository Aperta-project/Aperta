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
  end

  def save
    task.save!
    add_creator_as_participant
    task
  end

  private

  def default_options
    {
      title: task_klass::DEFAULT_TITLE,
      old_role: task_klass::DEFAULT_ROLE
    }
  end

  def add_creator_as_participant
    return unless (task.class <=> SubmissionTask) && creator
    ParticipationFactory.create(task: task, assignee: creator, notify: notify)
  end
end
