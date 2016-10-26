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
    invitations.each do |invitation|
      invitation.update(invitation_queue: queue)
      if invitation.has_alternates?
        grouped_primaries << invitation
      end
    end
    # put grouped primaries and alternates in queue
    grouped_invitations = []

    # Newly associated primaries bubble to the top
    grouped_primaries.sort! do |a,b|
      result = a.alternates.newest_first.first.created_at <=> b.alternates.newest_first.first.created_at
    end

    grouped_primaries.each do |primary|
      grouped_invitations << primary
      grouped_invitations.concat(primary.alternates.rescinded.order(:rescinded_at).all)
      grouped_invitations.concat(primary.alternates.invited.order(:invited_at).all)
      grouped_invitations.concat(primary.alternates.pending.order(:created_at).all)
    end

    #grouped_invitations.each do |invitation| puts "invitation.id #{invitation.id} position: #{invitation.position} body: #{invitation.body}" end && nil

    grouped_invitations = grouped_invitations.select(&:present?)

    remaining_invitations = invitations - grouped_invitations
    #TODO: put sent invitations first, sort sent by invited_at, sort the rest by created_at

    reordered_invitations = grouped_invitations + remaining_invitations

    # reordered_invitations = reordered_invitations.each_with_index do |i, pos|
    #   Invitation.update_all(position: pos + 1)
    #   i.reload
    # end
    #TODO: manually assign the 'position' field to reordered_invitations in the order they're in at this point.
    # The tests should make sure that the positions are correct
    queue.invitations = reordered_invitations.reverse

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
