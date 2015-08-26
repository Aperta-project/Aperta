class PaperRole::Destroyed::EventStream::NotifyPaperMembers < EventStreamSubscriber

  # This class listens for a paper_role destroy action and then
  # sends the paper with updated roles down the paper channel.
  #
  # You might expect to see the destroyed paper_role id be sent down the
  # system channel, but here is why:  there is no ember model representing
  # paper_role, so the only way to receive the most recent paper_roles is
  # by sending the whole Paper down the Paper channel. There are several
  # different ways we represent PaperRole on the client side (Collaborators,
  # Editors (User model), Reviewers (User model)), but none of them are
  # consistent and all are poor substitutes for being able to manage the
  # relationship directly.
  #
  # In addition, you do not want to send this paper payload down the system
  # channel with a 'destroyed' action because the ember client will destroy
  # the entire paper in the Ember Data Store for everyone subscribed to that
  # Paper channel. Definitely not what we want.
  #
  # Once there is an ember concept of a paper_role model, this class can
  # behave in a more sane way.

  def channel
    private_channel_for(record.paper)
  end

  def payload
    PaperSerializer.new(record.paper)
  end

  def action
    'updated'
  end

end
