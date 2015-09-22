class Author::Updated::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def run
    record.paper.authors.each do |author|
      TahiPusher::Channel.delay(queue: :eventstream, retry: false).
        push(channel_name: channel,
             event_name: action,
             payload: payload_for_record(author),
             excluded_socket_id: excluded_socket_id)
    end
  end
end
