json.flows @flows do |(flow_title, tasks)|
  json.title flow_title
  json.paperProfiles tasks do |(paper, tasks)|
    json.paper_path manage_paper_path(paper)
    json.title paper.display_title
    json.tasks (tasks.map { |task| TaskPresenter.for(task).data_attributes })
  end
end
