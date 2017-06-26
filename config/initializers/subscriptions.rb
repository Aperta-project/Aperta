##
# To see *all* subscriptions, try `rake subscriptions`!
#
# For event stream subscriptions, check out event_stream_subscribers.rb
#
Subscriptions.configure do
  add '.*', \
      EventLogger

  add 'paper:submitted', \
      Paper::Submitted::EmailCreator,
      Paper::Submitted::SnapshotPaper,
      Paper::Submitted::EmailCoauthors

  add 'paper:initially_submitted', \
      Paper::Submitted::SnapshotPaper,
      Paper::Submitted::EmailCreator

  add 'paper:updated', \
      Paper::Updated::MarkTitleAndAbstractIncomplete

  add 'discussion_reply:created', \
      DiscussionReply::Created::EmailPeopleMentioned,
      DiscussionReply::Created::NotifyPeopleMentioned

  add 'discussion_participant:created', \
      DiscussionParticipant::Created::EmailNewParticipant,
      Notification::Badger

  add 'discussion_participant:destroyed', \
      Notification::Unbadger

  add 'manuscript_attachment:created', \
      ManuscriptAttachment::ProcessManuscript

  add 'manuscript_attachment:updated', \
      ManuscriptAttachment::ProcessManuscript
end
