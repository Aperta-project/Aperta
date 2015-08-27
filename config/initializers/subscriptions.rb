TahiNotifier.subscribe("paper:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the paper down the paper channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("task:*", "author:*", "figure:*", "invitation:*", "supporting_information_file:*", "attachment:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the respective model down the paper channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record.paper, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("invitation:updated") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the invitation model down the user channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record.invitee, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("comment:*", "participation:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the comment or participation down the paper channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record.task.paper, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("question_attachment:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the question_attachment down the paper channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record.question.task.paper, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("paper_role:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the paper down the paper channel
  EventStream::Broadcaster.new(record.paper).post(action: action, channel_scope: record.paper, excluded_socket_id: excluded_socket_id)

  # serialize the paper down the user channel
  # this is necessary if the user is just now given access to the paper and have yet to subscribe to the paper channel
  EventStream::Broadcaster.new(record.paper).post(action: action, channel_scope: record.user, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("comment_look:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the comment_look down the user channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record.user, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("discussion_topic:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the discussion_topic down the discussion_topic channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("discussion_participant:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the discussion_participant down the discussion_topic channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record.discussion_topic, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("discussion_participant:created") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the discussion_participant down the user channel so they can subscribe to the topic
  EventStream::Broadcaster.new(record).post(action: "discussion-participant-created", channel_scope: record.user, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("discussion_reply:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the discussion_reply down the discussion_topic channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record.discussion_topic, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("activity:*") do |payload|
  action = payload[:action]
  subject = payload[:subject]
  user = payload[:user]
  source = payload[:source]

  ActivityFactoryUgh.createActivity(action, subject, user, source)
end
