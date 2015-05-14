TahiNotifier.subscribe("paper:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the paper down the paper channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("task:*", "author:*", "figure:*", "invitation:*", "supporting_information_file:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the respective model down the paper channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record.paper, excluded_socket_id: excluded_socket_id)
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

  # serialize the paper down the user channel
  EventStream::Broadcaster.new(record.paper).post(action: action, channel_scope: record.user, excluded_socket_id: excluded_socket_id)
end

TahiNotifier.subscribe("comment_look:*") do |payload|
  action = payload[:action]
  record = payload[:record]
  excluded_socket_id = payload[:requester_socket_id]

  # serialize the comment_look down the user channel
  EventStream::Broadcaster.new(record).post(action: action, channel_scope: record.user, excluded_socket_id: excluded_socket_id)
end
