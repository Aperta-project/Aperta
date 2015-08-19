class Paper::Updated::Pusher < PusherSubscriber

  def resource
    record
  end

  def channel
    record
  end

end
