# Notes that the title and abstract may have been updated
#
class Paper::Updated::MarkTitleAndAbstractIncomplete
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    return unless processing_changed(paper)

    paper.tasks.of_type(TahiStandardTasks::TitleAndAbstractTask)
      .map(&:incomplete!)
  end

  def self.processing_changed(paper)
    return unless paper.previous_changes && paper.previous_changes['processing']
    paper.previous_changes['processing'][0] !=
      paper.previous_changes['processing'][1]
  end
end
