class Attachment::Updated::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def payload
    AttachmentSerializer.new(record).to_json
  end

end
