class PaperRole::Destroyed::NotifyPaperMembers < PusherSubscriber

  def channel
    record.paper
  end

  def payload
    record.paper.payload
  end

end
