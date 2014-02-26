json.phases @phases do |phase|
  json.id phase.id
  json.name phase.name
  json.tasks (phase.tasks.map { |task| TaskPresenter.for(task).data_attributes })
end
json.paper do
  json.paper_short_title truncated_title(@paper)
  json.assignees @paper.journal.admins.map { |u| [u.id, u.full_name] }
  json.url paper_tasks_path(@paper, format: :json)
end
