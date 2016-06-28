# Notes that the title and abstract may have been updated
#
class Paper::Updated::MarkTitleAndAbstractIncomplete
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    return unless title_changed(paper) || abstract_changed(paper)

    paper.tasks.of_type(TahiStandardTasks::TitleAndAbstractTask)
      .map(&:incomplete!)
  end

  def self.title_changed(paper)
    return unless paper.previous_changes && paper.previous_changes['title']
    paper.previous_changes['title'][0] != paper.previous_changes['title'][1]
  end

  def self.abstract_changed(paper)
    return unless paper.previous_changes && paper.previous_changes['abstract']
    paper.previous_changes['abstract'][0] !=
      paper.previous_changes['abstract'][1]
  end
end
