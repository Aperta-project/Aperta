TahiNotifier.subscribe("task:created", "task:updated", "comment:*", "survey:*") do |name, start, finish, id, payload|
  action     = payload[:action]
  task_id    = payload[:task_id]
  journal_id = payload[:journal_id]

  task = Task.find(task_id)
  serializer = task.active_model_serializer.new(task)
  EventStream.post_event(
    journal_id,
    serializer.to_json
  )
end

TahiNotifier.subscribe("task:destroyed") do |name, start, finish, id, payload|
  action     = payload[:action]
  task_id    = payload[:task_id]
  journal_id = payload[:journal_id]

  EventStream.post_event(
    journal_id,
    { action: "destroy", task_ids: [task_id] }.to_json
  )
end
