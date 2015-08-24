class PlosAuthors::PlosAuthor::Updated::NotifyPlosAuthorChange < EventStreamSubscriber

  # There is a great deal of historical weirdness for the existence and collaboration
  # between an Author and PlosAuthor (see: https://github.com/Tahi-project/tahi/pull/369 and
  # https://github.com/Tahi-project/tahi/pull/427). The gem `active_record-acts_as` was
  # introduced to help address some of these issues by introducing a multitable inheritance
  # strategy.
  #
  # A `plos_author` (containing specific plos related attributes) will always have a corresponding
  # `author` record (containing generic attributes).  However, when an `author` record is
  # changed, the `plos_author` is not event streamed and the client interface is bound to 
  # `plos_authors`.
  #
  # This particular subscriber will event stream the `plos_author` when the `author` record is
  # changed.

  def channel
    record.paper
  end

  def payload
    record.actable.payload
  end

  def run
    super if record.actable.previous_changes.blank?
  end

end
