##
# To see *all* subscriptions, try `rake subscriptions`!
#

stream_to_paper_channel = EventStream::StreamToPaperChannel
stream_to_everyone = EventStream::StreamToEveryone
stream_to_user = EventStream::StreamToUser
stream_to_discussion_channel = EventStream::StreamToDiscussionChannel
stream_to_orcid_account_channel = EventStream::StreamToOrcidAccountChannel
stream_to_admin = EventStream::StreamToAdmin

Subscriptions.configure do

  # Journals

  add 'journal:created', AdminJournal::NotifyAdmin
  add 'journal:updated', AdminJournal::NotifyAdmin
  add 'journal:destroyed', AdminJournal::NotifyAdmin

  # Assgnments

  add 'assignment:created', Assignment::NotifyAssignee
  add 'assignment:updated', Assignment::NotifyAssignee
  add 'assignment:destroyed', Assignment::NotifyAssignee

  # Papers:

  add 'paper:updated', stream_to_paper_channel
  add 'paper:destroyed', stream_to_everyone
  add 'paper:data_extracted', Paper::DataExtracted::NotifyUser

  # Paper constituents:

  add 'task:created', stream_to_paper_channel
  add 'task:updated', stream_to_paper_channel
  add 'task:destroyed', stream_to_everyone

  add 'question_attachment:created', stream_to_paper_channel
  add 'question_attachment:updated', stream_to_paper_channel
  add 'question_attachment:destroyed', stream_to_everyone

  add 'figure:created', stream_to_paper_channel
  add 'figure:updated', stream_to_paper_channel
  add 'figure:destroyed', stream_to_everyone

  add 'supporting_information_file:created', stream_to_paper_channel
  add 'supporting_information_file:updated', stream_to_paper_channel
  add 'supporting_information_file:destroyed', stream_to_everyone

  add 'attachment:created', stream_to_paper_channel
  add 'attachment:updated', stream_to_paper_channel
  add 'attachment:destroyed', stream_to_everyone

  add 'decision:created', stream_to_paper_channel
  add 'decision:updated', stream_to_paper_channel
  add 'decision:destroyed', stream_to_everyone

  add 'invitation:created', stream_to_paper_channel
  add 'invitation:updated', stream_to_paper_channel, Invitation::Updated::EventStream::NotifyInvitee
  add 'invitation:destroyed', stream_to_everyone
  add 'invitation:accepted', Invitation::Updated::StateChange
  add 'invitation:declined', Invitation::Updated::StateChange
  add 'invitation:invited', Invitation::Updated::StateChange
  add 'invitation:rescinded', Invitation::Updated::StateChange

  add 'versioned_text:created', stream_to_paper_channel
  add 'versioned_text:updated', stream_to_paper_channel

  # Paper constituents that don't get 'updated':

  add 'comment:created', stream_to_paper_channel
  add 'comment:destroyed', stream_to_everyone

  add 'notification:created', stream_to_user
  add 'notification:destroyed', stream_to_user

  add 'participation:created', stream_to_paper_channel
  add 'participation:destroyed', stream_to_everyone

  # Paper constituents that have wierd special cases:

  add 'comment_look:created', stream_to_user
  add 'comment_look:destroyed', stream_to_user

  add 'author:created', Author::Created::EventStream
  add 'author:updated', Author::Updated::EventStream
  add 'author:destroyed', Author::Destroyed::EventStream

  # Discussions:

  add 'discussion_topic:created', stream_to_discussion_channel
  add 'discussion_topic:updated', stream_to_discussion_channel
  add 'discussion_topic:destroyed', stream_to_everyone

  add 'discussion_participant:created', stream_to_discussion_channel, DiscussionParticipant::Created::EventStream::NotifyAssignee
  add 'discussion_participant:destroyed', stream_to_everyone

  add 'discussion_reply:created', stream_to_discussion_channel
  add 'discussion_reply:updated', stream_to_discussion_channel
  add 'discussion_reply:destroyed', stream_to_everyone

  # Orcid Accounts:

  add 'orcid_account:updated', stream_to_orcid_account_channel

  add 'card:created', stream_to_admin
  add 'card:updated', stream_to_admin
  add 'card:destroyed', stream_to_admin
end
