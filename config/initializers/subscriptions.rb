Subscriptions.configure do
  add '.*', EventLogger

  add 'paper:updated', Paper::Updated::EventStream
  add 'paper:destroyed', Paper::Destroyed::EventStream
  add 'paper:submitted', Paper::Submitted::EmailCreator, Paper::Submitted::EmailAdmins, Paper::Submitted::KeenLogger
  add 'paper:resubmitted', Paper::Resubmitted::EmailEditor

  add 'paper_role:created', PaperRole::Created::EventStream::NotifyPaperMembers, PaperRole::Created::EventStream::NotifyAssignee
  add 'paper_role:destroyed', PaperRole::Destroyed::EventStream::NotifyPaperMembers, PaperRole::Destroyed::EventStream::NotifyAssignee

  add 'task:created', Task::Created::EventStream
  # -1, when reordering on workflow
  add 'task:updated', Task::Updated::EventStream
  add 'task:destroyed', Task::Destroyed::EventStream

  add 'question_attachment:created', QuestionAttachment::Created::EventStream
  add 'question_attachment:updated', QuestionAttachment::Updated::EventStream
  add 'question_attachment:destroyed', QuestionAttachment::Destroyed::EventStream

  add 'figure:created', Figure::Created::EventStream
  add 'figure:updated', Figure::Updated::EventStream
  add 'figure:destroyed', Figure::Destroyed::EventStream

  add 'supporting_information_file:created', SupportingInformationFile::Created::EventStream
  add 'supporting_information_file:updated', SupportingInformationFile::Updated::EventStream
  add 'supporting_information_file:destroyed', SupportingInformationFile::Destroyed::EventStream

  add 'attachment:created', Attachment::Created::EventStream
  add 'attachment:updated', Attachment::Updated::EventStream
  add 'attachment:destroyed', Attachment::Destroyed::EventStream

  add 'invitation:created', Invitation::Created::EventStream::NotifyPaperMembers
  add 'invitation:updated', Invitation::Updated::EventStream::NotifyPaperMembers, Invitation::Updated::EventStream::NotifyInvitee
  add 'invitation:destroyed', Invitation::Destroyed::EventStream

  add 'comment:created', Comment::Created::EventStream
  add 'comment:destroyed', Comment::Destroyed::EventStream

  add 'comment_look:created', CommentLook::Created::EventStream
  add 'comment_look:destroyed', CommentLook::Destroyed::EventStream

  add 'author:created', Author::Created::EventStream
  add 'author:updated', Author::Updated::EventStream
  add 'author:destroyed', Author::Destroyed::EventStream

  add 'participation:created', Participation::Created::EventStream
  add 'participation:destroyed', Participation::Destroyed::EventStream

  add 'discussion_topic:created', DiscussionTopic::Created::EventStream
  add 'discussion_topic:updated', DiscussionTopic::Updated::EventStream
  add 'discussion_topic:destroyed', DiscussionTopic::Destroyed::EventStream

  add 'discussion_participant:created', DiscussionParticipant::Created::EventStream::NotifyExistingParticipants, DiscussionParticipant::Created::EventStream::NotifyAssignee
  add 'discussion_participant:destroyed', DiscussionParticipant::Destroyed::EventStream

  add 'discussion_reply:created', DiscussionReply::Created::EventStream
  add 'discussion_reply:updated', DiscussionReply::Updated::EventStream
  add 'discussion_reply:destroyed', DiscussionReply::Destroyed::EventStream
end
