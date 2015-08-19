class Paper::Updated::Pusher < PusherSubscriber

  def channel
    record
  end

  def payload
    record.payload
  end

end
