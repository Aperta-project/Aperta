class Paper::Destroyed::Pusher < PusherSubscriber

  def resource
    record
  end

  def channel
    record.paper
  end

end
