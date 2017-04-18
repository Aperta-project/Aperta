# TaskFactory is the sole class responsible for actually adding new Task
# instances to a paper
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
    unless options[:card_version].present? || options["card_version"].present?
      options[:card_version] = Card.find_by(name: task_klass.name)
                                 .try(:card_version, :latest)
    end
    @task = task_klass.new(options)
  end

  def save
    task.save!
    task
  end

  private

  def default_options
    {
      title: task_klass::DEFAULT_TITLE
    }
  end
end
