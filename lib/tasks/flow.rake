namespace :flow do
  desc "Generate default flows"
  task :generate_defaults => :environment  do
    Flow.defaults.destroy_all
    Flow.create(title: 'Up for grabs', query: {assigned: false, state: :incomplete})
    Flow.create(title: 'My papers', query: {type: "StandardTasks::PaperAdminTask"})
    Flow.create(title: 'My tasks', query: {state: :incomplete, assigned: true})
    Flow.create(title: 'Done', query: {state: :completed, assigned: true})
  end
end
