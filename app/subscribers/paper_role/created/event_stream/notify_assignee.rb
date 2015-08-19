class PaperRole::Created::EventStream::NotifyAssignee < EventStreamSubscriber

  # this is necessary when the user is just now given access to the paper
  # and has yet to subscribe to the paper channel

  def channel
    record.user
  end

  def payload
    assignee = record.user
    record.paper.payload(user: assignee)
  end

end
