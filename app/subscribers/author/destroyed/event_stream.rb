class Author::Destroyed::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def send_destroyed_message
    TahiPusher::Channel.delay(queue: :eventstream, retry: false)
      .push(channel_name: system_channel,
            event_name: "destroyed",
            payload: payload_for_record(record),
            excluded_socket_id: excluded_socket_id)
  end

  def update_author_indexes
    record.paper.authors.each do |author|
      TahiPusher::Channel.delay(queue: :eventstream, retry: false)
        .push(channel_name: channel,
              event_name: "updated",
              payload: payload_for_record(author),
              excluded_socket_id: excluded_socket_id)
    end
  end

  def run
    send_destroyed_message
    update_author_indexes
  end
end
