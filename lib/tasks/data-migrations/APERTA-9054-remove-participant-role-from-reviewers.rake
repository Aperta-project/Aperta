namespace :data do
  namespace :migrate do
    namespace :reviewers do
      desc <<-DESC
        APERTA-9054: This removes reviewers as participants on their Reviewer Report Task which
        ensures that reviewers are not granted permissions to the discussion panel and they
        only have the permissions appropriate to their role.
      DESC
      task remove_participant_roles: :environment do
        relevant_tasks = ['TahiStandardTasks::ReviewerReportTask', 'TahiStandardTasks::FrontMatterReviewerReportTask']
        set_of_reviewer_report_ids = Task.all.where(type: relevant_tasks).pluck(:id)

        User.joins(:roles).where(roles: {name: 'Reviewer'}).find_each do |reviewer|
          reviewer.participations.where(assigned_to_id: set_of_reviewer_report_ids).each_do |assignment|
            STDOUT.puts("Deleting Reviewer #{reviewer.id}'s participation assignment #{assignment.id}...")
            assignment.destroy!
          end
        end
      end

      desc <<-DESC
        APERTA-9054: This adds back reviewers as participants on their Reviewer Report Task
      DESC
      task add_back_participant_roles: :environment do
      end
    end
  end
end
