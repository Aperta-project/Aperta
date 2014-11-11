TahiNotifier.subscribe("author:created") do |subscription_name, payload|
  klass      = payload[:klass]
  id         = payload[:id]

  # generic Authors may have been created in a different task, so
  # convert them to PlosAuthors
  paper = klass.find(id).paper
  paper.tasks_for_type("PlosAuthors::PlosAuthorsTask").each do |task|
    task.convert_generic_authors!
  end
end

TahiNotifier.subscribe("plos_authors/plos_author:created", "plos_authors/plos_author:updated") do |subscription_name, payload|
  action     = payload[:action]
  klass      = payload[:klass]
  id         = payload[:id]

  EventStream.new(action, klass, id, subscription_name).post
end

TahiNotifier.subscribe("plos_authors/plos_author:destroyed") do |subscription_name, payload|
  id         = payload[:id]
  paper_id   = payload[:paper_id]

  EventStream.post_event(
    Paper,
    paper_id,
    { action: "destroyed", plos_authors: [id], subscription_name: subscription_name }.to_json
  )
end
