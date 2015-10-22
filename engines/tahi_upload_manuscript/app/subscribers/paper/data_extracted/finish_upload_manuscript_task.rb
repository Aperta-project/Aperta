class Paper::DataExtracted::FinishUploadManuscriptTask

  def self.call(_event_name, event_data)
    paper = event_data[:record]

    paper.tasks_for_type("TahiUploadManuscript::UploadManuscriptTask").each do |task|
      task.complete!
    end
  end

end
