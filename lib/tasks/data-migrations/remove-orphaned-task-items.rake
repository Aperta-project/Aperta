namespace :data do
  namespace :migrate do
    desc "Remove orphaned task items"
    task remove_orphaned_task_items: :environment do
      TahiStandardTasks::ApexDelivery.where(task_id: nil).destroy_all
      TahiStandardTasks::Funder.where(task_id: nil).destroy_all
      TahiStandardTasks::ReviewerRecommendation.where(
        reviewer_recommendations_task_id: nil
      ).destroy_all
    end
  end
end
