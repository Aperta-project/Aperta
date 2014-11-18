TahiNotifier.subscribe("author:created") do |subscription_name, payload|
  record = payload[:record]

  # generic Authors may have been created in a different task, so
  # convert them to PlosAuthors
  record.paper.tasks_for_type("PlosAuthors::PlosAuthorsTask").each do |task|
    task.convert_generic_authors!
  end
end

TahiNotifier.subscribe("plos_authors/plos_author:created", "plos_authors/plos_author:updated") do |subscription_name, payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(action, record, subscription_name).post
end

TahiNotifier.subscribe("plos_authors/plos_author:destroyed") do |subscription_name, payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(action, record, subscription_name).destroy
end
