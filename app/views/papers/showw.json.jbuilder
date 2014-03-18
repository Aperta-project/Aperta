json.paper do
  json.id @paper.id
  json.short_title @paper.short_title
  json.title @paper.title
  json.phase_ids do
    json.array! @paper.phase_ids
  end
end

json.phases do
  json.array! @phases do |p|
    json.id p.id
    json.name p.name
    json.position p.position
    json.paper_id @paper.id
    json.task_ids p
    json.tasks p.tasks do |task|
      json.id task.id
      json.type task.type
    end
  end
end

json.tasks do
  json.array! @tasks do |task|
    json.id task.id
    json.name task.name
    json.type task.type
    json.completed task.completed
    json.assignee_ids task.assignees.map(&:id)
    json.assignee_id task.assignee_id
  end
end

json.users do

end
