#TODO: refactor so that subscribe() takes array
#TODO: refactor so that subscribe() can take a splat such as 'comment:*'
update_listeners = ["task:created", "task:updated", "comment:created", "comment:updated", "comment:destroyed", "survey:created", "survey:updated", "survey:destroyed"]
update_listeners.each do |ns|
  ActiveSupport::Notifications.subscribe(ns) do |name, start, finish, id, payload|
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
end

ActiveSupport::Notifications.subscribe('task:destroyed') do |name, start, finish, id, payload|
    action     = payload[:action]
    task_id    = payload[:task_id]
    journal_id = payload[:journal_id]

    #TODO: probably need to pull out this hash into a serializer?
    EventStream.post_event(
      journal_id,
      { action: "destroy", task_ids: [task_id] }.to_json
    )
end
