class ChangeReviseManuscriptToResponseToReviewers < ActiveRecord::Migration
  def change
    revise_tasks = Task.where(type: TahiStandardTasks::ReviseTask)
    revise_tasks.update_all(title: 'Response to Reviewers')
  end
end
