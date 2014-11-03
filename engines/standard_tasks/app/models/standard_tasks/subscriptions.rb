TahiNotifier.subscribe("task:created", "task:updated", "comment:*") do |subscription_name, payload|
  action = payload[:action]
  task = Task.find(payload[:task_id])
  if task.type == "StandardTasks::PaperEditorTask"
    dashboard_serializer = DashboardSerializer.new({}, user: User.find(task.editor_id))
    # update editor dashboard
    EventStream.post_event(
      User,
      task.editor_id,
      dashboard_serializer.as_json.merge(action: action, subscription_name: subscription_name).to_json
    )
  end
end
