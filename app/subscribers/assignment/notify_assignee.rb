# Notify the system of assignment changes
class Assignment::NotifyAssignee < EventStreamSubscriber
  def channel
    private_channel_for(record.user)
  end

  def payload
    payload_for_record(record.assigned_to)
  end

  def run
    # Pushing a user payload would result in Ember trying to get a user from
    # an api/user route. No such route exists, so we prohibit sending updates
    # for anything assigned to a user
    super unless record.assigned_to.is_a? User
  end
end
