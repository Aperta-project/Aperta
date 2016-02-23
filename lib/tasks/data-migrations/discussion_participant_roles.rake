# rubocop:disable all
namespace :data do
  namespace :migrate do
    namespace :discussion_participants do
      desc 'Migrates discussion participants to use new R&P task assignments'
      task make_into_new_roles: :environment do
        DiscussionParticipant.all.each do |discussion_participant|
          if discussion_participant.user.blank?
            # remove orphaned pariticipations as we go
            discussion_participant.delete
          else
            user = discussion_participant.user
            topic = discussion_participant.discussion_topic
            discussion_participant_role = topic.journal.discussion_participant_role
            puts "Assigning #{user.full_name} <#{user.email}> as #{discussion_participant_role.name} on '#{topic.title}' Discussion Topic"
            Assignment.where(
              assigned_to: topic,
              user: user,
              role: discussion_participant_role
            ).first_or_create!
          end
        end
      end
    end
  end
end
