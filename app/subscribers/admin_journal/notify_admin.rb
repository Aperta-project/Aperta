# Notify admins when a journal change has occurred,
# but have the client request for the record go to
# the admin_journals controller instead of the default
# public journals controller.
class AdminJournal::NotifyAdmin < EventStreamSubscriber
  def channel
    admin_channel
  end

  def payload
    {
      type: 'admin_journal',
      id: record.id
    }
  end
end
