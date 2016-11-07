class Paper::DataExtracted::FinishUploadManuscriptTask
  def self.call(_event_name, event_data)
    return unless event_data[:record].completed?
    paper = Paper.find(event_data[:record].paper_id)
    paper.tasks_for_type(TahiStandardTasks::UploadManuscriptTask.to_s).each(&:complete!)
  end
end
