# TODO: Make a data migration to go with this once it's actually working
namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-5579: Migrates invitations to place them within queues instead of tasks.
    DESC
    task migrate_invitations_to_queues: :environment do
      Task.where(type: 'TahiStandardTasks::PaperReviewerTask').find_each do |task|
        task.paper.decisions.each do |decision|
          puts "making queue for decision #{decision.id}"
          queue = decision.create_invitation_queue!(task: task)
          put_invitations_into_queue(decision.invitations, queue)
        end
      end
      Task.where(type: 'TahiStandardTasks::PaperEditorTask').find_each do |task|
        puts "making queue for task #{task.id}"
        queue = task.create_invitation_queue!(task: task)
        put_invitations_into_queue(task.invitations, queue)
      end
    end
  end

  def put_invitations_into_queue(invitations, queue)
    grouped_primaries = []
    # get grouped invitations
    invitations.each do |invite|
      invite.update(invitation_queue: queue)
      if invite.has_alternates?
        grouped_primaries << invite
      end
    end

    # put grouped primaries and alternates in queue
    grouped_invitations = []
    grouped_primaries.each do |primary|
      grouped_invitations << primary
      grouped_invitations.concat(primary.alternates.rescinded.all)
      grouped_invitations.concat(primary.alternates.invited.all)
      grouped_invitations.concat(primary.alternates.pending.all)
    end

    grouped_invitations = grouped_invitations.select(&:present?)

    remaining_invitations = invitations - grouped_invitations

    reordered_invitations = grouped_invitations + remaining_invitations

    queue.invitations = reordered_invitations
    queue.save
  end

  desc <<-DESC
      APERTA-5579: Migration removes queues to default to task-invitations association

      This is intended to be run as part of a down migration.
  DESC
  task :migrate_queues_back_to_invitations do
    InvitationQueue.destroy_all
  end
end
