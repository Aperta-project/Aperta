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
        set_of_reviewer_report_ids = Task.where(type: relevant_tasks).pluck(:id)
        deletion_count = 0
        user_count = 0
        reviewer_count = 0
        removed_participations = []
        assignment_count = 0

        # Assertions to check the integrity of the data
        User.joins(:roles).where(roles: { name: 'Reviewer Report Owner' }).map do |reviewer|
          reviewer_count += 1
          reviewer_report_ids = reviewer.tasks.where(type: relevant_tasks).pluck(:id).uniq
          reviewer_report_ids.each do |reviewer_report_id|
            reviewer.participations.where(assigned_to_id: reviewer_report_id).each do
              assignment_count += 1
            end
          end
        end
        number_of_reviewer_reports = set_of_reviewer_report_ids.count

        STDOUT.puts("Assignment count: #{assignment_count}, Reviewer Report count: #{number_of_reviewer_reports}")
        if assignment_count > number_of_reviewer_reports
          STDERR.puts("Number of participants (#{assignment_count}) is higher than the amount of Reviewer Reports (#{number_of_reviewer_reports}. Please review the data and fix before trying again.")
          raise "Reviewer participants higher than Reviewer Reports"
        end

        User.joins(:roles).where(roles: { name: 'Reviewer Report Owner' }).find_each do |reviewer|
          user_count += 1
          reviewer_report_ids = reviewer.tasks.where(type: relevant_tasks).pluck(:id).uniq
          reviewer_report_ids.each do |reviewer_report_id|
            reviewer.participations.where(assigned_to_id: reviewer_report_id).each do |assignment|
              removed_participations << {
                task: assignment.assigned_to.id,
                assigner: reviewer.id,
                assignee: reviewer.id
              }
              STDOUT.puts("Deleting Reviewer Report Owner #{reviewer.id}'s participation assignment #{assignment.id} for paper #{assignment.assigned_to.paper.short_doi}...")
              assignment.destroy!
              deletion_count += 1
            end
          end
        end
        STDOUT.puts("-------------------------------------")
        STDOUT.puts("#{removed_participations.join(',')}")

        STDOUT.puts("Reviewer_count: #{reviewer_count}, User_count: #{user_count}")
        STDOUT.puts("Assignment count: #{assignment_count}, Reviewer Report count: #{number_of_reviewer_reports}")
        STDOUT.puts("Deleted #{deletion_count} participation assignments:")
      end

      desc <<-DESC
        APERTA-9054: This makes all reviewers participants on their Reviewer Report Task
      DESC
      task add_back_participant_roles: :environment do
        # irreversible
        raise ActiveRecord::IrreversibleMigration, "Some participations were removed manually from \
         Reviewer Tasks so they cannot be added automatically without adding a participation for \
         every Reviewer Report."
        # To reverse the previous migration take the output logs of the up migration for the deleted participations
        # and iterate through them with ParticipationFactory

        # THIS MAY ADD BACK REVIEWERS AS PARTICIPANTS WHO WERE PREVIOUSLY REMOVED AS PARTICIPANTS
        relevant_tasks = ['TahiStandardTasks::ReviewerReportTask', 'TahiStandardTasks::FrontMatterReviewerReportTask']
        set_of_reviewer_report_ids = Task.where(type: relevant_tasks).pluck(:id)
        set_of_reviewer_report_owner_role_ids = Role.where(name: 'Reviewer Report Owner').pluck(:id)
        added_count = 0
        user_count = 0

        Role.where(name: 'Reviewer Report Owner').each do |owner_role|
          user_count += 1
          owner_role.users.each do |reviewer_report_owner|
            reviewer_report_owner.assignments.where(assigned_to_type: 'Task', assigned_to_id: set_of_reviewer_report_ids).where(role_id: set_of_reviewer_report_owner_role_ids).each do |report_owner_assignment|
                                                task = report_owner_assignment.assigned_to
                                                reviewer_report_owner = report_owner_assignment.user
                                                STDOUT.puts("Adding back Reviewer Report Owner #{reviewer_report_owner.id}'s participation...")
                                                participation = ParticipationFactory.create(task: task, assignee: reviewer_report_owner, assigner: reviewer_report_owner, notify: false)
                                                if participation.present?
                                                  added_count += 1
                                                  STDOUT.puts("Created participation for Reviewer Report Owner #{reviewer_report_owner.id} for paper #{task.paper.id}")
                                                else
                                                  if task.participants.include? reviewer_report_owner
                                                    participation = task.participations.find_by(user: reviewer_report_owner)
                                                    STDOUT.puts("Already have participation #{participation.id} for Reviewer Report Owner #{reviewer_report_owner.id}")
                                                  else
                                                    STDERR.puts("Failed to create participation for Reviewer Report Owner #{reviewer_report_owner.id}")
                                                    fail "Error with creating participation for Reviewer Report Owner #{reviewer_report_owner.id}"
                                                  end
                                                end
                                             end
          STDOUT.puts("-------------------------------------")
          STDOUT.puts("Added #{added_count} participations for #{user_count} Reviewer Report Owners")
          end
        end
      end
    end
  end
end
