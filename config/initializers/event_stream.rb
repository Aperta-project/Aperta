ActiveSupport::Notifications.subscribe('updated') do |name, start, finish, id, payload|
  task = Task.find(payload[:id])
  ts = task.active_model_serializer.new(task)
  EventStream.post_event(task.paper.id, ts.as_json.merge({type: ts.type}).to_json)
end

