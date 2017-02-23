# Streams things of interest to people viewing the admin pages
class EventStream::StreamToAdmin < EventStreamSubscriber
  def channel
    admin_channel
  end
end
