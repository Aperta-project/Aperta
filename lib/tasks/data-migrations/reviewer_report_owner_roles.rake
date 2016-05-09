# rubocop:disable all
namespace :data do
  namespace :migrate do
    desc <<-DESC.gsub(/^\s*\|/, '')
      |Migrates reviewer(s) to have the reviewer report owner role.
      |
      |This is idempotent and safe to run multiple times.
    DESC
    task reviewer_report_owners: :environment do
      TahiStandardTasks::ReviewerReportTask.all.each do |task|
        # Find the first participation for the current reviewer report task
        participation = task.participations
          .includes(:user)
          .order('assignments.id asc')
          .first

        # We should always have a participation
        if participation
          # The first participation is always the reviewer so make an
          # explicit assignment to the task as a reviewer report owner.
          print "Setting reviewer report owner for #{task.inspect}"
          task.assignments.where(
            role: task.journal.reviewer_report_owner_role,
            user: participation.user
          ).first_or_create!
          puts "done."
        else
          STDERR.puts <<-EOT.gsub(/^\s*\|/, '')
            |WARNING: #{task.inspect} doesn't have any participations.
            |  Paper created by: #{task.paper.creator.full_name} (username=#{task.paper.creator.username})
            |  If the user is a test account then it is likely a result of QA testing. Otherwise,
            |  we may need to ask if reviewers are being removed as participants of their own
            |  review as part of the paper lifecycle by a human (e.g. a staff or editorial user).
          EOT
        end
      end
    end
  end
end
