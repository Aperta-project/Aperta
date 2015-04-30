TahiNotifier.subscribe("paper:*") do |payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(record).post(action: action, channel_scope: record)
end

TahiNotifier.subscribe("task:*", "author:*", "figure:*", "invitation:*", "supporting_information_file:*") do |payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(record).post(action: action, channel_scope: record.paper)
end

TahiNotifier.subscribe("comment:*", "participation:*") do |payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(record).post(action: action, channel_scope: record.task.paper)
end

TahiNotifier.subscribe("question_attachment:*") do |payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(record).post(action: action, channel_scope: record.question.task.paper)
end

# TahiNotifier.subscribe("paper_role:*") do |payload|
#   action = payload[:action]
#   record = payload[:record]
# 
#   EventStream.new(record).post(action: action, channel_scope: record.paper)
# end
