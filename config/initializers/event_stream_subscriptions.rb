TahiNotifier.subscribe("paper_role:created") do |payload|
  user_id  = payload[:user_id]
  paper_id = payload[:paper_id]
  action   = payload[:action]
  meta     = payload[:meta]

  paper    = Paper.find(paper_id)
  serializer = LitePaperSerializer.new(paper, user: User.find(user_id))

  EventStream.post_event(
    User,
    user_id,
    serializer.as_json.merge(action: action, meta: meta).to_json
  )
end

TahiNotifier.subscribe("task:created", "task:updated", "comment:*") do |payload|
  action     = payload[:action]
  task_id    = payload[:task_id]
  paper_id   = payload[:paper_id]
  meta       = payload[:meta]

  task = Task.find(task_id)
  serializer = task.active_model_serializer.new(task)
  EventStream.post_event(
    Paper,
    paper_id,
    serializer.as_json.merge(action: action, meta: meta).to_json
  )
end

TahiNotifier.subscribe("supporting_information/file:*", "figure:*", "paper:*", "paper_role:created", "question_attachment:*") do |payload|
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
    serializer.as_json.merge(action: action, meta: meta).to_json
  )
end

TahiNotifier.subscribe("task:destroyed") do |payload|
  action     = payload[:action]
  task_id    = payload[:task_id]
  paper_id   = payload[:paper_id]

  EventStream.post_event(
    Paper,
    paper_id,
    { action: "destroy", tasks: [task_id] }.to_json
  )
end

TahiNotifier.subscribe("paper_role:destroyed") do |payload|
  user_id  = payload[:user_id]
  paper_id = payload[:paper_id]

  EventStream.post_event(
    User,
    user_id,
    { action: "destroy", lite_papers: [paper_id] }.to_json
  )
end
