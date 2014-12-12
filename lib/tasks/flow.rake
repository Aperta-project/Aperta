namespace :flow do
  desc "Generate default flows"
  task :generate_defaults => :environment  do
    Flow.defaults.destroy_all
    Flow.create(title: 'Up for grabs', assigned_query: 'false', state_query: 'incomplete')
    Flow.create(title: 'My tasks', state_query: 'incomplete', assigned_query: 'true')
    Flow.create(title: 'Done', state_query: 'completed', assigned_query: 'true')
  end
end
