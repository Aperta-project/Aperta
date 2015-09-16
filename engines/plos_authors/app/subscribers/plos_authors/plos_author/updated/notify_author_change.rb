class PlosAuthors::PlosAuthor::Updated::NotifyAuthorChange < EventStreamSubscriber

  # There is a great deal of historical weirdness for the existence and collaboration
  # between an Author and PlosAuthor (see: https://github.com/Tahi-project/tahi/pull/369 and
  # https://github.com/Tahi-project/tahi/pull/427). The gem `active_record-acts_as` was
  # introduced to help address some of these issues by introducing a multitable inheritance
  # strategy.
  #
  # A `plos_author` (containing specific plos related attributes) will always have a corresponding
  # `author` record (containing generic attributes).  However, when an `plos_author` record is
  # changed, the `author` is not event streamed, causing the client data store to be out of sync.
  #
  # This particular subscriber will event stream the `author` when the `plos_author` record is
  # changed.

  def channel
    private_channel_for(record.paper)
  end

  def payload
    ::AuthorsSerializer.new(record.paper.authors, root: :authors).as_json
  end

  def run
    super if record.author.previous_changes.blank?
  end

end
