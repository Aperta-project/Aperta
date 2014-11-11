TahiNotifier.subscribe(
  "participation:created", "participation:updated",
  "comment:created", "comment:updated",
  "task:created", "task:updated",
  "paper:created", "paper:updated",
  "author:created", "author:updated",
  "figure:created", "figure:updated",
  "question_attachment:created", "question_attachment:updated") do |subscription_name, payload|
  action     = payload[:action]
  klass      = payload[:klass]
  id         = payload[:id]

  EventStream.new(action, klass, id, subscription_name).post
end

TahiNotifier.subscribe(
  "author:destroyed",
  "task:destroyed",
  "participation:destroyed") do |subscription_name, payload|
  action     = payload[:action]
  klass      = payload[:klass]
  id         = payload[:id]

  EventStream.new(action, klass, id, subscription_name).destroy
end
