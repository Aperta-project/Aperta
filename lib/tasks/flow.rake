namespace :flow do
  desc "Generate default flows"
  task :generate_defaults => :environment  do
    Flow.defaults.destroy_all
    Flow.create(title: 'Up for grabs', query: {unassigned: true, incomplete: true})
    Flow.create(title: 'My papers', query: {admin: true})
    Flow.create(title: 'My tasks', query: {incomplete: true, assigned: true})
    Flow.create(title: 'Done', query: {complete: true, assigned: true})
  end
end
