namespace :data do
  namespace :migrate do
    desc "Remove orphaned task items"
    task remove_orphaned_task_items: :environment do
      ApexDelivery.all.select do |delivery|
        delivery.task.nil?
      end.map(&:destroy)

      Funder.all.select do |funder|
        funder.task.nil?
      end.map(&:destroy)

      ReviewerRecommendation.all.select do |recommendation|
        recommendation.task.nil?
      end.map(&:destroy)
    end
  end
end
