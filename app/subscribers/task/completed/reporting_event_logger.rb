class Task::Completed::ReportingEventLogger < ReportingEventSubscriber

  def build_event
    paper = record.paper

    ReportingEvent.new do |es|
      es.name = :task_completed
      es.journal_id = paper.journal_id
      es.paper_id = paper.id
      es.data = {
        completed: record.completed,
        body: record.body
      }
    end
  end

end
