class RegisterDecisionTask::Completed::EventStoreLogger < EventStoreSubscriber

  def build_event
    decision = record.paper.decisions.last_round

    EventStore.new do |es|
      es.journal_id = record.paper.journal_id
      es.paper_id = record.paper.id
      es.data = {
        verdict: decision.verdict,
        revision_number: decision.revision_number
      }
    end
  end

end
