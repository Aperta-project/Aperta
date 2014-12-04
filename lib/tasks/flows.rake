namespace :flows do
  desc "Create default role flows"
  task :generate_defaults => :environment do
    Flow.where(title: 'Up for grabs', query: [:unassigned, :incomplete], default: true).first_or_create
    Flow.where(title: 'My papers', query: [:admin], default: true).first_or_create
    Flow.where(title: 'My tasks', query: [:incomplete, :assigned], default: true).first_or_create
    Flow.where(title: 'Done', query: [:completed, :assigned], default: true).first_or_create
  end
end

