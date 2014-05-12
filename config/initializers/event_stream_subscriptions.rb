ActiveSupport::Notifications.subscribe('updated') do |name, start, finish, id, payload|
  task = Task.find(payload[:id])
  serializer = task.active_model_serializer.new(task)
  EventStream.post_event(
    task.journal.id,
    serializer.to_json
  )
end

ActiveSupport::Notifications.subscribe('deleted') do |name, start, finish, id, payload|
  EventStream.post_event(
    payload[:journal_id],
    { taskId: payload[:id], deleted: true }.to_json
  )
end
