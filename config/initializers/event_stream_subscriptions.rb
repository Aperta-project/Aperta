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

TahiNotifier.subscribe("supporting_information/file:*", "figure:*", "paper:*", "question_attachment:*") do |payload|
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
    { action: "destroyed", tasks: [task_id] }.to_json
  )
end

TahiNotifier.subscribe("paper_role:created") do |payload|
  user_id  = payload[:user_id]
  paper_id = payload[:paper_id]
  action   = payload[:action]
  meta     = payload[:meta]
  id       = payload[:id]

  paper_role = PaperRole.find(id)
  user_id = paper_role.user.id
  paper    = Paper.find(paper_id)
  dashboard_serializer = DashboardSerializer.new({}, user: User.find(user_id))

  # update user dashboard
  EventStream.post_event(
    User,
    user_id,
    dashboard_serializer.as_json.merge(action: action, meta: meta).to_json
  )

  # update user streams
  EventStream.post_event(
    User,
    user_id,
    { action: "updateStreams" }.to_json
  )
end

TahiNotifier.subscribe("paper_role:destroyed") do |payload|
  user_id  = payload[:user_id]
  paper_id = payload[:paper_id]

  # only remove paper if the user has no other access to it
  unless PaperRole.for_user(user_id).pluck(:paper_id).include?(paper_id)
    EventStream.post_event(
      User,
      user_id,
      { action: "destroyed", lite_papers: [paper_id] }.to_json
    )

    EventStream.post_event(
      User,
      user_id,
      { action: "updateStreams" }.to_json
    )
  end
end
