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
      Paper::Submitted::EmailCoauthors,
      Paper::Salesforce,
      Paper::Submitted::ReopenRevisionTasks,
      Paper::Submitted::CreateReviewerReports

  add 'paper:initially_submitted', \
      Paper::Submitted::SnapshotPaper,
      Paper::Submitted::EmailCreator

  add 'paper:in_revision', Paper::DecisionMade::UnassignReviewers

  add 'paper:accepted', \
      Paper::DecisionMade::UnassignReviewers,
      Paper::Salesforce

  add 'paper:rejected', \
      Paper::Salesforce,
      Paper::DecisionMade::UnassignReviewers

  add 'paper:withdrawn', \
      Paper::Salesforce,
      Paper::DecisionMade::UnassignReviewers

  add 'discussion_reply:created', \
      DiscussionReply::Created::EmailPeopleMentioned,
      DiscussionReply::Created::NotifyPeopleMentioned

  add 'discussion_participant:created', \
      DiscussionParticipant::Created::EmailNewParticipant,
      Notification::Badger

  add 'discussion_participant:destroyed', \
      Notification::Unbadger
end
