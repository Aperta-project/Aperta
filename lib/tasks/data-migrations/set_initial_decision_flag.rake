namespace :data do
  namespace :migrate do
    namespace :decisions do
      desc "Initialize the 'initial' flag on Decisions"
      task set_initial_decision: :environment do
        Decision.transaction do
          Paper.where(gradual_engagement: true).find_each do |paper|
            first_decision = paper.decisions.order('created_at asc').first
            first_decision.update! initial: true if first_decision.completed?
          end
        end
      end
    end
  end
end
