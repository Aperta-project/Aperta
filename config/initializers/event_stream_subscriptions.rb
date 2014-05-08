ActiveSupport::Notifications.subscribe('updated') do |name, start, finish, id, payload|
  task = Task.find(payload[:id])
  serializer = task.active_model_serializer.new(task)
  EventStream.post_event(
    task.journal.id,
    serializer.to_json
  )
end
