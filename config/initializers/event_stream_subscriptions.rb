TahiNotifier.subscribe(
  "participation:created", "participation:updated",
  "comment:created", "comment:updated",
  "task:created", "task:updated",
  "paper:created", "paper:updated",
  "paper_role:created", "paper_role:updated",
  "author:created", "author:updated",
  "figure:created", "figure:updated",
  "question_attachment:created", "question_attachment:updated") do |subscription_name, payload|
  action     = payload[:action]
  klass      = payload[:klass]
  id         = payload[:id]

  EventStream.new(action, klass, id, subscription_name).post
end


TahiNotifier.subscribe(
  "author:destroyed",
  "task:destroyed",
  "participation:destroyed") do |subscription_name, payload|
  action     = payload[:action]
  klass      = payload[:klass]
  id         = payload[:id]

  EventStream.new(action, klass, id, subscription_name).destroy
end


TahiNotifier.subscribe("paper_role:destroyed") do |subscription_name, payload|
  user_id  = payload[:user_id]
  paper_id = payload[:paper_id]

  # only remove paper if the user has no other access to it
  unless PaperRole.for_user(user_id).pluck(:paper_id).include?(paper_id)
    EventStream.post_user_event(
      user_id,
      { action: "destroyed", lite_papers: [paper_id], subscription_name: subscription_name }.to_json
    )

    EventStream.post_user_event(
      user_id,
      { action: "updateStreams", subscription_name: subscription_name }.to_json
    )
  end
end
