class Attachment::Updated::EventStream < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    AttachmentSerializer.new(record).to_json
  end

end
