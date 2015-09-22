class PaperRole::Destroyed::EventStream::NotifyAssignee < EventStreamSubscriber

  def channel
    private_channel_for(record.user)
  end

  def payload
    payload_for_record record.paper
  end

  def run
    super if record.paper.paper_roles.where(user: record.user).count == 0
  end
end
