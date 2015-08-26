class PaperRole::Destroyed::EventStream::NotifyPaperMembers < EventStreamSubscriber

  # notify the users associated to the paper that a
  # paper role has been destroyed by sending the paper itself.
  # this is because there currently is not a paper_role ember model.

  def channel
    record.paper
  end

  def payload
    PaperSerializer.new(record.paper)
  end

end
