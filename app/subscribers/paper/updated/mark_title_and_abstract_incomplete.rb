# Notes that the title and abstract may have been updated
#
class Paper::Updated::MarkTitleAndAbstractIncomplete
  def self.call(_event_name, event_data)
    paper = event_data[:record]

    unless paper.processing
      paper.tasks.of_type(TahiStandardTasks::TitleAndAbstractTask)
        .map(&:incomplete!)
    end
  end
end
