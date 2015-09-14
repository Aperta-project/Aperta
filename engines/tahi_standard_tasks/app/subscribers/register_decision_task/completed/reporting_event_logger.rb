class RegisterDecisionTask::Completed::ReportingEventLogger < ReportingEventSubscriber

  def build_event
    decision = record.paper.decisions.last_round

    ReportingEvent.new do |es|
      es.name = :decision_registered
      es.journal_id = record.paper.journal_id
      es.paper_id = record.paper.id
      es.data = {
        verdict: decision.try(:verdict),
        revision_number: decision.try(:revision_number)
      }
    end
  end

end
