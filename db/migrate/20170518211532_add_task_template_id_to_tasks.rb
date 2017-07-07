class AddTaskTemplateIdToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :task_template, index: true
  end
end
