class PaperRole::Destroyed::EventStream::NotifyPaperMembers < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    record.paper.payload
  end

end
