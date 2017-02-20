class Paper::DataExtracted::FinishUploadManuscriptTask
  def self.call(_event_name, event_data)
    return unless event_data[:record].completed?
    paper = Paper.find(event_data[:record].paper_id)
    unless paper.file_type == 'pdf'
      paper.tasks_for_type(TahiStandardTasks::UploadManuscriptTask.to_s).each do |task|
        task.complete!
        Activity.task_updated! task, user: User.find(event_data[:record].user_id)
      end
    end
  end
end
