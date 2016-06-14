# Notes that the title and abstract may have been updated
#
class Paper::Updated::MarkTitleAndAbstractIncomplete
  def self.call(_event_name, event_data)
    paper = event_data[:record]

    unless paper.processing
      tasks = paper.tasks.where(type: "TahiStandardTasks::TitleAndAbstractTask")
      tasks.map do |task|
        task.completed = false
        task.save!
      end
    end
  end
end
