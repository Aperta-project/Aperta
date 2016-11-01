
# Module to contain the migration's functions rather than
# defining them on Kernel
module QueueMigration
  def self.put_invitations_into_queue(invitations, queue)
    grouped_primaries = []
    # get grouped primaries in order of creation
    #
    invitations.each do |invitation|
      grouped_primaries << invitation if invitation.has_alternates?
    end
    # put grouped primaries and alternates in queue
    grouped_invitations = []

    # Newly associated primaries bubble to the top
    grouped_primaries.sort! do |a, b|
      b.alternates.newest_first.first.created_at <=> a.alternates.newest_first.first.created_at
    end

    grouped_primaries.each do |primary|
      grouped_invitations << primary
      grouped_invitations.concat(primary.alternates.not_pending.order(invited_at: :desc).all)
      grouped_invitations.concat(primary.alternates.pending.order(created_at: :desc).all)
    end

    grouped_invitations.flatten!

    remaining_invitations = invitations - grouped_invitations

    # 'sent' is really everything that's not pending anymore
    remaining_sent = remaining_invitations.select { |i| i.state != 'pending' }.sort_by(&:invited_at)
    remaining_pending = remaining_invitations.select { |i| i.state == 'pending' }.sort_by(&:created_at)

    reordered_invitations = grouped_invitations + remaining_sent + remaining_pending

    queue.invitations = reordered_invitations
    queue.save!

    # manually reorder according to our sorted positions.
    reordered_invitations.each_with_index do |i, pos|
      i.update_columns(position: pos + 1)
    end
  end

  def self.migrate_up
    Task.where(type: 'TahiStandardTasks::PaperReviewerTask').find_each do |task|
      task.paper.decisions.each do |decision|
        puts "making queue for decision #{decision.id}"
        queue = decision.invitation_queue || decision.create_invitation_queue!(task: task)
        put_invitations_into_queue(decision.invitations, queue)
      end
    end
    Task.where(type: 'TahiStandardTasks::PaperEditorTask').find_each do |task|
      puts "making queue for task #{task.id}"
      queue = task.invitation_queue || task.create_invitation_queue!(task: task)
      put_invitations_into_queue(task.invitations, queue)
    end
  end

  def self.migrate_down
    InvitationQueue.destroy_all
  end
end

namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-5579: Migrates invitations to place them within queues instead of tasks.
    DESC
    task migrate_invitations_to_queues: :environment do
      QueueMigration.migrate_up
    end
  end

  desc <<-DESC
      APERTA-5579: Migration removes queues to default to task-invitations association

      This is intended to be run as part of a down migration.
  DESC
  task :migrate_queues_back_to_invitations do
    QueueMigration.migrate_down
  end
end
