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
  end
end
