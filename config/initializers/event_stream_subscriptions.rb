events = %W(task:created task:updated comment:* supporting_information/file:* figure:* paper:* question_attachment:*)
TahiNotifier.subscribe(*events) do |name, start, finish, id, payload|

  EventStream.post_event(
    payload[:paper_id],
    payload.to_json
  )
end

TahiNotifier.subscribe("task:destroyed") do |name, start, finish, id, payload|
  action     = payload[:action]
  task_id    = payload[:id]
  paper_id   = payload[:paper_id]

  EventStream.post_event(
    paper_id,
    { action: "destroy", task_ids: [task_id] }.to_json
  )
end
