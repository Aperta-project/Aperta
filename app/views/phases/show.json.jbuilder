json.phase do
  json.id @phase.id
  json.name @phase.name
  json.position @phase.position
  json.tasks (@phase.tasks.map { |task| TaskPresenter.for(task).data_attributes })
end
