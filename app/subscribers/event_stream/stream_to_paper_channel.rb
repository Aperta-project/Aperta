class EventStream::StreamToPaperChannel < EventStreamSubscriber
  def channel
    if record.is_a? Paper
      private_channel_for(record)
    elsif record.paper
      private_channel_for(record.paper)
    end
  end
end
