ActiveSupport::Notifications.subscribe('updated') do |name, start, finish, id, payload|
  task = Task.find(payload[:id])
  serializer = task.active_model_serializer.new(task)
  EventStream.post_event(
    task.paper.id,
    serializer.as_json.merge({type: serializer.type}).to_json
  )
end
