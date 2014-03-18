json.paper do
  json.id @paper.id
  json.short_title @paper.short_title
  json.title @paper.title
  json.phase_ids do
    json.array! @paper.phase_ids
  end
end

json.phases do
  json.array! @paper.phases do |p|
    json.id p.id
    json.name p.name
    json.position p.position
    json.paper_id @paper.id
    json.tasks p.tasks do |task|
      json.id task.id
      json.type task.type
    end
  end
end

json.tasks do
  json.array! @tasks do |task|
    json.id task.id
    json.title task.title
    json.type task.type
    json.completed task.completed
    json.message_subject task.message_subject
    json.phase_id task.phase_id
    json.assignee_ids task.assignees.map(&:id)
    json.assignee_id task.assignee_id
  end
end

json.users do
  json.array! @users, :id, :full_name, :image_url
end
