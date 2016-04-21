# rubocop:disable all
namespace :data do
  namespace :migrate do
    namespace :billing_tasks do
      desc 'populates missing required permissions for tasks'
      task set_missing_required_permissions: :environment do
        PlosBilling::BillingTask.find_each do |t|
          t.required_permissions = t.journal_task_type.required_permissions
          t.save!
        end
      end
    end
  end
end
