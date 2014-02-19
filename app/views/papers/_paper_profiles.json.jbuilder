json.title flow_title
json.paperProfiles tasks do |(paper, tasks)|
  json.title paper.title
  json.tasks (tasks.map { |task| TaskPresenter.for(task).data_attributes })
end
