json.title 'My Tasks'
json.paperProfiles @my_tasks do |paper, tasks|
  json.title tasks[0].title
  json.tasks tasks[1]
end
