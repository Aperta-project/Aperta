TahiNotifier.subscribe("task:created", "task:updated", "comment:*", "declaration::survey:*") do |name, start, finish, id, payload|
  action     = payload[:action]
  task_id    = payload[:task_id]
  paper_id   = payload[:paper_id]
  meta       = payload[:meta]

  task = Task.find(task_id)
  serializer = task.active_model_serializer.new(task)
  EventStream.post_event(
    paper_id,
    serializer.as_json.merge(action: action, meta: meta).to_json
  )
end

TahiNotifier.subscribe("task:destroyed") do |name, start, finish, id, payload|
  action     = payload[:action]
  task_id    = payload[:task_id]
  paper_id   = payload[:paper_id]

  EventStream.post_event(
    paper_id,
    { action: "destroy", task_ids: [task_id] }.to_json
  )
end
