create_update_events = [
  "comment:created", "comment:updated",
  # "task:created", "task:updated",
  "paper:created", "paper:updated",
  "author:created", "author:updated",
  "figure:created", "figure:updated",
  "question_attachment:created", "question_attachment:updated",
  "invitation:updated"
]

TahiNotifier.subscribe(create_update_events) do |subscription_name, payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(action, record, subscription_name).post
end

TahiNotifier.subscribe("task:*") do |payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(record).post(action: action, channel_scope: record.paper)
end

TahiNotifier.subscribe("author:destroyed",
                       # "task:destroyed",
                       "participation:destroyed", "figure:destroyed", "invitation:destroyed") do |subscription_name, payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(action, record, subscription_name).destroy
end

TahiNotifier.subscribe("paper_role:created", "participation:created") do |subscription_name, payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(action, record.paper, subscription_name).post
end

TahiNotifier.subscribe("paper_role:destroyed") do |subscription_name, payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(action, record.paper, subscription_name).destroy_for(record.user)
end

TahiNotifier.subscribe("supporting_information_file:created", "supporting_information_file:updated") do |subscription_name, payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(action, record, subscription_name).post
end
