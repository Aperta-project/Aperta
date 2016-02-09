# rubocop:disable all
namespace :data do
  namespace :migrate do
    namespace :participants do
      desc 'Migrates task participants to use new R&P task assignments'
      task make_into_new_roles: :environment do
        Participation.all.includes(:user, :task).each do |participation|
          if participation.task.blank?
            # remove orphaned pariticipations as we go
            # do not call destroy since that may invoke code that
            # tries to look up the paper which it no longer has access to
            participation.delete
          else
            participant_role = participation.task.journal.roles.participant
            user = participation.user
            task = participation.task
            puts "Assigning #{user.full_name} <#{user.email}> as #{participant_role.name} on '#{task.title}' Task"
            Assignment.where(
              assigned_to: participation.task,
              user: user,
              role: participant_role
            ).first_or_create!
          end
        end
      end
    end
  end
end
