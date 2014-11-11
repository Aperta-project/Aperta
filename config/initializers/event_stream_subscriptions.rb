TahiNotifier.subscribe(
  "participation:created", "participation:updated",
  "comment:created", "comment:updated",
  "task:created", "task:updated",
  "paper:created", "paper:updated",
  "paper_role:created", "paper_role:updated",
  "author:created", "author:updated",
  "figure:created", "figure:updated") do |subscription_name, payload|
  action     = payload[:action]
  klass      = payload[:klass]
  id         = payload[:id]

  EventStream.new(action, klass, id, subscription_name).post
end

TahiNotifier.subscribe("supporting_information/file:*", "question_attachment:*") do |subscription_name, payload|
  action     = payload[:action]
  id         = payload[:id]
  paper_id   = payload[:paper_id]
  meta       = payload[:meta]
  klass      = payload[:klass]

  record = klass.find(id)
  serializer = record.event_stream_serializer.new(record)
  EventStream.post_event(
    Paper,
    paper_id,
    serializer.as_json.merge(action: action, meta: meta, subscription_name: subscription_name).to_json
  )
end

TahiNotifier.subscribe("author:destroyed") do |subscription_name, payload|
  id         = payload[:id]
  paper_id   = payload[:paper_id]

  EventStream.post_event(
    Paper,
    paper_id,
    { action: "destroyed", authors: [id], subscription_name: subscription_name }.to_json
  )
end

TahiNotifier.subscribe("task:destroyed") do |subscription_name, payload|
  task_id    = payload[:task_id]
  paper_id   = payload[:paper_id]

  EventStream.post_event(
    Paper,
    paper_id,
    { action: "destroyed", tasks: [task_id], subscription_name: subscription_name }.to_json
  )
end


TahiNotifier.subscribe("paper_role:destroyed") do |subscription_name, payload|
  user_id  = payload[:user_id]
  paper_id = payload[:paper_id]

  # only remove paper if the user has no other access to it
  unless PaperRole.for_user(user_id).pluck(:paper_id).include?(paper_id)
    EventStream.post_event(
      User,
      user_id,
      { action: "destroyed", lite_papers: [paper_id], subscription_name: subscription_name }.to_json
    )

    EventStream.post_event(
      User,
      user_id,
      { action: "updateStreams", subscription_name: subscription_name }.to_json
    )
  end
end
TahiNotifier.subscribe("participation:destroyed") do |subscription_name, payload|
  paper_id = payload[:paper_id]
  id       = payload[:id]

  EventStream.post_event(
    Paper,
    paper_id,
    { action: "destroyed", participations: [id], subscription_name: subscription_name }.to_json
  )
end

