class RegisterDecisionTask::Completed::KeenLogger < KeenSubscriber

  def collection
    :tasks
  end

  def payload
    decision = record.paper.decisions.last_round

    {
      id: record.id,
      paper: record.paper.id,
      type: record.type,
      verdict: decision.verdict,
      revision_number: decision.revision_number,
    }
  end

end
