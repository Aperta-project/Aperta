# Notes that the title and abstract may have been updated
#
class Paper::Updated::MarkTitleAndAbstractIncomplete
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    return unless paper.previous_changes && paper.previous_changes['processing']

    paper.tasks.of_type(TahiStandardTasks::TitleAndAbstractTask)
      .map(&:incomplete!)
  end
end
