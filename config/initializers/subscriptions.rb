##
# To see *all* subscriptions, try `rake subscriptions`!
#
# For event stream subscriptions, check out event_stream_subscribers.rb
#

unassign_reviewers = Paper::DecisionMade::UnassignReviewers
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

  add 'paper:in_revision', unassign_reviewers
  add 'paper:accepted', unassign_reviewers
  add 'paper:rejected', unassign_reviewers
  add 'paper:withdrawn', unassign_reviewers

end
