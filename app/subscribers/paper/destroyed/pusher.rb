class Paper::Destroyed::Pusher < PusherSubscriber

  def channel
    record.paper
  end

  def payload
    record.destroyed_payload
  end

end
