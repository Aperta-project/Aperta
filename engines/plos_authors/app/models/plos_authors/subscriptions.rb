TahiNotifier.subscribe("author:created") do |subscription_name, payload|
  action     = payload[:action]
  id         = payload[:id]
  paper_id   = payload[:paper_id]
  meta       = payload[:meta]
  klass      = payload[:klass]

  # generic Authors may have been created in a different task, so
  # convert them to PlosAuthors
  paper = Paper.find_by(id: paper_id)
  paper.tasks_for_type("PlosAuthors::PlosAuthorsTask").each do |task|
    task.convert_generic_authors!
  end
end

TahiNotifier.subscribe("plos_authors/plos_author:created", "plos_authors/plos_author:updated") do |subscription_name, payload|
  action     = payload[:action]
  id         = payload[:id]
  paper_id   = payload[:paper_id]
  meta       = payload[:meta]
  klass      = payload[:klass]

  record = klass.find(id)
  paper = Paper.find(paper_id)
  serializer = record.event_stream_serializer
  serializer.root = false
  authors = klass.for_paper(paper).map { |a| serializer.new(a).as_json }
  authors_payload = {plos_authors: authors}
  EventStream.post_event(
    Paper,
    paper_id,
    authors_payload.merge(action: action, meta: meta, subscription_name: subscription_name).to_json
  )
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
