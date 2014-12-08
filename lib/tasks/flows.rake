namespace :flows do
  desc "Create default role flows"
  task :generate_defaults => :environment do
    Flow.where(title: 'Up for grabs', query: [:unassigned, :incomplete]).first_or_create
    Flow.where(title: 'My papers', query: [:admin]).first_or_create
    Flow.where(title: 'My tasks', query: [:incomplete, :assigned]).first_or_create
    Flow.where(title: 'Done', query: [:completed, :assigned]).first_or_create
  end
end

