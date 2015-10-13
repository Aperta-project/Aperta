class TaskFactory

  attr_reader :task, :task_klass, :creator

  def initialize(task_klass, options = {})
    @task_klass = task_klass
    @creator = options.delete(:creator)
    options = default_options.merge(options)
    @task = task_klass.constantize.new(options)
  end

  def create!
    add_creator_as_participant
    task.save!
    task
  end

  def self.build(task_klass, task_params)
    role = find_role(task_klass, task_params[:phase_id])
    task_klass.new(task_params.merge(role: role))
  end

  def self.find_role(task_klass, phase_id)
    Phase.find(phase_id).journal.journal_task_types.find_by(kind: task_klass).role
  end

  private

  def default_options
    {
      title: TaskType.types[task_klass].fetch(:default_title),
      role: TaskType.types[task_klass].fetch(:default_role)
    }
  end

  def add_creator_as_participant
    if task.submission_task? && creator && task.participants.exclude?(creator)
      task.participants << creator
    end
  end
end
