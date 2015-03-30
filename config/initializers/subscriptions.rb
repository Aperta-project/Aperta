create_update_events = [
  "comment:created", "comment:updated",
  "task:created", "task:updated",
  "paper:created", "paper:updated",
  "author:created", "author:updated",
  "figure:created", "figure:updated",
  "question_attachment:created", "question_attachment:updated",
  "invitation:updated"
]



TahiNotifier.subscribe("task::updated") do |subscription_name, payload|
  action = payload[:action]
  record = payload[:record]
  channel_name_models = { paper: 13, task: 44 }



  channel = "private-user_4-paper_#{record.paper.id}"
  channel = "private-user_4-paper_33-task_13"
  channel_suffix = "paper_33-task_13"

  EventStream.new(action, record, subscription_name).post
end

TahiNotifier.subscribe(create_update_events) do |subscription_name, payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(action, record, subscription_name).post
end

TahiNotifier.subscribe("author:destroyed", "task:destroyed", "participation:destroyed", "figure:destroyed", "invitation:destroyed") do |subscription_name, payload|
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
