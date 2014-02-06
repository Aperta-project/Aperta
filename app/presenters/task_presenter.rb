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
      'task-title' => task.title,
      'task-body' => task.body,
      'card-name' => task.class.name.underscore.dasherize.gsub(/-task/, ''),
      'assignee-id' => task.assignee_id,
      'assignees' => assignees,
      'task-id' => task.id
    }
  end

  # TODO: test me
  def self.for(task)
    "#{task.class.name}Presenter".constantize.new(task)
  end

  protected

  def assignees
    select_options_for_users(task.assignees).to_json
  end

  def select_options_for_users(users)
    users.map { |u| [u.id, u.full_name] }
  end
end
