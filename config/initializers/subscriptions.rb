##
# To see *all* subscriptions, try `rake subscriptions`!
#
# For event stream subscriptions, check out event_stream_subscribers.rb
#

# rubocop:disable Style/AlignParameters
Subscriptions.configure do
  add '.*', \
      EventLogger

  add 'paper:submitted', \
      Paper::Submitted::EmailCreator,
      Paper::Submitted::EmailAdmins,
      Paper::Submitted::SnapshotPaper

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
      ManuscriptAttachment::SendManuscriptToIhat

  add 'manuscript_attachment:updated', \
      ManuscriptAttachment::SendManuscriptToIhat
end
# rubocop:enable Style/AlignParameters
