# TODO: Make a data migration to go with this once it's actually working
namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-5579: Migrates invitations to place them within queues instead of tasks.
    DESC
    task migrate_invitations_to_queues: :environment do
      Task.where(type: 'TahiStandardTasks::PaperReviewerTask').find_each do |task|
        task.paper.decisions.each do |decision|
          queue = decision.create_invite_queue!(task: task)
          put_invitations_into_queue(decision.invitations, queue)
        end
      end
      Task.where(type: 'TahiStandardTasks::PaperEditorTask').find_each do |task|
        queue = task.create_invite_queue!(task: task)
        put_invitations_into_queue(task.invitations, queue)
      end
    end
  end

  def put_invitations_into_queue(invitations, queue)
    grouped_primaries = []
    # get grouped invitations
    invitations.each do |invite|
      invite.update(invite_queue: queue)
      if invite.has_alternates?
        grouped_primaries << invite
      end
    end

    # get linked primaries, order them by date added
    # for each primary, get the alternates, order first by pending/sent, then by date added
  end

  desc <<-DESC
      APERTA-5579: Migration removes queues to default to task-invitations association

      This is intended to be run as part of a down migration.
  DESC
  task :migrate_queues_back_to_invitations do
    InviteQueue.destroy_all
  end
end
