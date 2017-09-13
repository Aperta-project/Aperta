# TaskFactory is the sole class responsible for actually adding new Task
# instances to a paper
class TaskFactory
  attr_reader :task, :task_klass

  def self.create(task_klass, options = {})
    task = new(task_klass, options).save
    task.task_added_to_paper(task.paper)
    task.create_answers
    task
  end

  def initialize(task_klass, options = {})
    @task_klass = task_klass

    task_options = default_options
                  .merge(options)
                  .except(:creator, :notify)
    @task = task_klass.new(task_options)
  end

  def save
    task.save!
    task
  end

  private

  def default_options
    HashWithIndifferentAccess.new(
      title: task_klass::DEFAULT_TITLE,
    )
  end
end
