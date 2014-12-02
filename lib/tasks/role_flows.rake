namespace :role_flows do
  desc "Create default role flows"
  task :generate_defaults => :environment do
    RoleFlow.where(title: 'Up for grabs', query: [:unassigned, :incomplete], default: true).first_or_create
    RoleFlow.where(title: 'My papers', query: [:admin, :paper], default: true).first_or_create
    RoleFlow.where(title: 'My tasks', query: [:incomplete, :assigned], default: true).first_or_create
    RoleFlow.where(title: 'Done', query: [:complete, :assigned], default: true).first_or_create
  end
end

