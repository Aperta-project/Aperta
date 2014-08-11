class TaskTemplate < ActiveRecord::Base
  belongs_to :phase_template, inverse_of: :task_templates
  belongs_to :journal_task_type

  def task_type
    journal_task_type.task_type
  end
end
