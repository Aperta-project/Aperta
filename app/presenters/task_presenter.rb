class TaskPresenter
  include Rails.application.routes.url_helpers

  private
  attr_reader :task

  public

  def initialize(task)
    @task = task
  end

  def data_attributes
    {
      'paper-title' => task.paper.title,
      'paper-path' => paper_path(task.paper),
      'paper-id' => task.paper.to_param,
      'task-path' => paper_task_path(task.paper, task), # TODO: remove me, use href
      'card-name' => task.class.name.underscore.dasherize.gsub(/-task/, ''),
      'assignee-id' => task.assignee_id,
      'assignees' => assignees
    }
  end

  # TODO: test me
  def self.for(task)
    "#{task.class.name}Presenter".constantize.new(task)
  end

  protected

  def assignees
    task.assignees.map { |a| [a.id, a.full_name] }.to_json
  end
end
