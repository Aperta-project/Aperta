class Attachment::Updated::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def payload
    AttachmentSerializer.new(record).as_json
  end

end
