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
      'paperTitle' => task.paper.title || task.paper.short_title,
      'paperPath' => paper_path(task.paper),
      'paperId' => task.paper.to_param,
      'taskPath' => paper_task_path(task.paper, task),
      'taskTitle' => task.title,
      'taskBody' => task.body,
      'taskCompleted' => task.completed?,
      'cardName' => task.class.name.underscore.dasherize.gsub(/-task/, ''),
      'assigneeId' => task.assignee_id,
      'assignees' => assignees,
      'taskId' => task.id
    }
  end

  def self.for(task)
    "#{task.class.name}Presenter".constantize.new(task)
  end

  protected

  def assignees
    select_options_for_users(task.assignees)
  end

  def select_options_for_users(users)
    users.map { |u| [u.id, u.full_name] }
  end
end
