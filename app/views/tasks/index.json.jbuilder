json.flows @phases do |phase|
  json.id phase.id
  json.name phase.name
  json.position phase.position
  json.tasks (phase.tasks.map { |task| TaskPresenter.for(task).data_attributes })
end

json.paper do
  json.id @paper.id
  json.paper_short_title truncated_title(@paper)
  json.assignees @paper.journal.admins.map { |u| [u.id, u.full_name] }
  json.tasks_url paper_tasks_path(@paper, format: :json)
  json.edit_url edit_paper_path(@paper, format: :json)
  json.journal_logo_url @paper.journal.logo_url
  json.journal_name @paper.journal.name
  json.task_manager_id @paper.task_manager.id
end
