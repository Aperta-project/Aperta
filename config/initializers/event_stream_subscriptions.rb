TahiNotifier.subscribe("task:created", "task:updated", "comment:*", "survey:*") do |payload|
  action     = payload[:action]
  task_id    = payload[:task_id]
  journal_id = payload[:journal_id]

  task = Task.find(task_id)
  serializer = task.active_model_serializer.new(task)
  EventStream.post_event(
    journal_id,
    serializer.as_json.merge(action: action).to_json
  )
end

TahiNotifier.subscribe("task:destroyed") do |payload|
  action     = payload[:action]
  task_id    = payload[:task_id]
  journal_id = payload[:journal_id]

  EventStream.post_event(
    journal_id,
    { action: "destroy", task_ids: [task_id] }.to_json
  )
end
