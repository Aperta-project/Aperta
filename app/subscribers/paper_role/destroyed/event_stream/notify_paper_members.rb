class PaperRole::Destroyed::EventStream::NotifyPaperMembers < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    record.paper.destroyed_payload
  end

end
