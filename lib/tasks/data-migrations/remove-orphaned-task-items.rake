namespace :data do
  namespace :migrate do
    desc "Remove orphaned task items"
    task remove_orphaned_task_items: :environment do
      TahiStandardTasks::ApexDelivery.all.select do |delivery|
        delivery.task.nil?
      end.map(&:destroy)

      TahiStandardTasks::Funder.all.select do |funder|
        funder.task.nil?
      end.map(&:destroy)

      TahiStandardTasks::ReviewerRecommendation.all.select do |recommendation|
        recommendation.task.nil?
      end.map(&:destroy)
    end
  end
end
