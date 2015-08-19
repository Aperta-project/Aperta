class PaperRole::Created::EventStream::NotifyPaperMembers < EventStreamSubscriber

  # notify the users associated to the paper that a new
  # paper role has been created

  def channel
    record.paper
  end

  def payload
    record.paper.payload
  end

end
