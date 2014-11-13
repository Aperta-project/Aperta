TahiNotifier.subscribe(
  "participation:created", "participation:updated",
  "comment:created", "comment:updated",
  "task:created", "task:updated",
  "paper:created", "paper:updated",
  "author:created", "author:updated",
  "figure:created", "figure:updated",
  "question_attachment:created", "question_attachment:updated") do |subscription_name, payload|
    action = payload[:action]
    record = payload[:record]

    EventStream.new(action, record, subscription_name).post
end

TahiNotifier.subscribe(
  "author:destroyed",
  "task:destroyed",
  "participation:destroyed") do |subscription_name, payload|
    action = payload[:action]
    record = payload[:record]

  EventStream.new(action, record, subscription_name).destroy
end
