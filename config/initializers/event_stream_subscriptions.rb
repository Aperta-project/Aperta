##
# To see *all* subscriptions, try `rake subscriptions`!
#

StreamToPaperChannel = EventStream::StreamToPaperChannel
StreamToEveryone = EventStream::StreamToEveryone
StreamToUser = EventStream::StreamToUser
StreamToDiscussionChannel = EventStream::StreamToDiscussionChannel

Subscriptions.configure do

  # Papers:

  add 'paper:updated', StreamToPaperChannel
  add 'paper:destroyed', StreamToEveryone

  # Paper constituents:

  add 'task:created', StreamToPaperChannel
  add 'task:updated', StreamToPaperChannel
  add 'task:destroyed', StreamToEveryone

  add 'question_attachment:created', StreamToPaperChannel
  add 'question_attachment:updated', StreamToPaperChannel
  add 'question_attachment:destroyed', StreamToEveryone

  add 'figure:created', StreamToPaperChannel
  add 'figure:updated', StreamToPaperChannel
  add 'figure:destroyed', StreamToEveryone

  add 'supporting_information_file:created', StreamToPaperChannel
  add 'supporting_information_file:updated', StreamToPaperChannel
  add 'supporting_information_file:destroyed', StreamToEveryone

  add 'attachment:created', StreamToPaperChannel
  add 'attachment:updated', StreamToPaperChannel
  add 'attachment:destroyed', StreamToEveryone

  add 'decision:created', StreamToPaperChannel
  add 'decision:updated', StreamToPaperChannel
  add 'decision:destroyed', StreamToEveryone

  add 'invitation:created', StreamToPaperChannel
  add 'invitation:updated', StreamToPaperChannel, Invitation::Updated::EventStream::NotifyInvitee
  add 'invitation:destroyed', StreamToEveryone

  # Paper constituents that don't get 'updated':

  add 'comment:created', StreamToPaperChannel
  add 'comment:destroyed', StreamToEveryone

  add 'participation:created', StreamToPaperChannel
  add 'participation:destroyed', StreamToEveryone

  # Paper constituents that have wierd special cases:

  add 'comment_look:created', StreamToUser
  add 'comment_look:destroyed', StreamToUser

  add 'paper_role:created', PaperRole::Created::EventStream::NotifyAssignee, PaperRole::Created::EventStream::NotifyEveryone
  add 'paper_role:destroyed', PaperRole::Destroyed::EventStream::NotifyAssignee, PaperRole::Destroyed::EventStream::NotifyEveryone

  add 'author:created', Author::Created::EventStream
  add 'author:updated', Author::Updated::EventStream
  add 'author:destroyed', Author::Destroyed::EventStream

  # Discussions:

  add 'discussion_topic:created', StreamToDiscussionChannel
  add 'discussion_topic:updated', StreamToDiscussionChannel
  add 'discussion_topic:destroyed', StreamToEveryone

  add 'discussion_participant:created', StreamToDiscussionChannel, DiscussionParticipant::Created::EventStream::NotifyAssignee
  add 'discussion_participant:destroyed', StreamToEveryone

  add 'discussion_reply:created', StreamToDiscussionChannel
  add 'discussion_reply:updated', StreamToDiscussionChannel
  add 'discussion_reply:destroyed', StreamToEveryone

end
