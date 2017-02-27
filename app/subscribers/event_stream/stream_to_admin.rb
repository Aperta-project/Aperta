# Streams things of interest to people viewing the admin pages. Admin
# things can't go down journal-specific streams (sometimes we view
# multiple journals simultaneously) and they can't go down the
# everyone-stream (because that's only for destroy messages) and they
# can't go down user-specific streams because they don't belong to
# single users. So we have a stream specific to the admin pages.
class EventStream::StreamToAdmin < EventStreamSubscriber
  def channel
    admin_channel
  end
end
