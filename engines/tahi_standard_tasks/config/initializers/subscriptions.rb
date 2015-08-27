STANDARD_TASK_EVENTS = {
  'paper:resubmitted' => [Paper::Resubmitted::ReopenRevisionTasks],
}

STANDARD_TASK_EVENTS.each do |event_name, subscriber_list|
  Notifier.subscribe(event_name, subscriber_list)
end
